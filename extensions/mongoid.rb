module Mongoid
  class Criteria

    def in_batches(sort_field, limit, options = {})
      _debug = options[:debug] != false
      _job = options[:job]

      dup_query = merge({})
      total = dup_query.count.to_i
      _job.atomically do |j|
        j.set(total_doc_count: total, query_selector: selector.to_json)
      end if _job
      remaining = total - _job.try(:processed_doc_count).to_i

      puts "SCROLL(#{klass}) by `#{sort_field}`. #{remaining} entries remaining.".blue if _debug

      docs = asc(sort_field).limit(limit).merge({})
      docs = docs.gt(sort_field => _job.last_processed_id) if _job && !_job.last_processed_id.nil?
      docs = docs.entries

      while docs.length > 0 do
        results = yield(docs) if block_given?
        last_id = docs.last[sort_field]
        last_ts = docs.last.timestamp if docs.last.respond_to?(:timestamp)

        rest = asc(sort_field).gt(sort_field => last_id).merge({})
        remaining -= docs.length
        if remaining < 0 # new docs were inserted after the initial count
          total = dup_query.count.to_i
        end

        _job.atomically do |j|
          j.inc(processed_doc_count: docs.length)
          j.set(total_doc_count: total) if total != j.total_doc_count
          j.set(last_processed_id: last_id, last_processed_timestamp: last_ts)
        end if _job

        puts "SCROLL(#{klass}) after #{sort_field} => #{last_id}..." <<
             "#{remaining} documents remaining" if _debug
        docs = rest.limit(limit).entries
      end
    end

  end
end
