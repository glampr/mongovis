class BulkWriter

  def self.upsert_all(docs, collection, options = {})
    commands = docs.map do |d|
      doc = d.as_document.to_h.deep_symbolize_keys if d.respond_to?(:as_document)
      # Will not be need after https://jira.mongodb.org/browse/MONGOID-4280
      doc = d.deep_symbolize_keys if d.respond_to?(:deep_symbolize_keys)
      update = doc.any? { |k, v| k.to_s.starts_with?("$") } ? doc : {"$set" => doc}
      document_id = doc[:_id] || doc.fetch(:$set, {})[:_id] || doc.fetch(:$setOnInsert, {})[:_id]
      {update_one: {filter: {_id: document_id }, update: update, upsert: true}}
    end
    store_all(commands, collection, options)
  end

  def self.update_all(docs, collection, options = {})
    commands = docs.map do |d|
      doc = d.as_document.to_h.deep_symbolize_keys if d.respond_to?(:as_document)
      # Will not be need after https://jira.mongodb.org/browse/MONGOID-4280
      doc = d.deep_symbolize_keys if d.respond_to?(:deep_symbolize_keys)
      update = doc.any? { |k, v| k.to_s.starts_with?("$") } ? doc : {"$set" => doc}
      {update_one: {filter: {_id: doc[:_id]}, update: update}}
    end
    store_all(commands, collection, options)
  end

  def self.store_all(commands, collection, options = {})
    begin
      result = collection.bulk_write(commands, ordered: !!options[:ordered]) unless commands.blank?
      puts result.inspect.gsub(/"upserted_ids"=>\[.*\]/, "").blue
      result
    rescue => ex
      puts ex.result.inspect.red
      raise ex
    end
  end

end
