require 'bundler/setup'
require 'securerandom'
require 'time'

Bundler.require

class RefreshTest
  INDEX = 'refresh-test'.freeze
  TYPE  = 'messages'.freeze

  def initialize(client)
    @client = client
  end

  def action!
    data = generate_message

    insert(data)
    refresh_result = refresh
    search_result  = search(data.fetch(:user_id))
    search_result_size = search_result.fetch('hits').fetch('hits').size

    total = refresh_result.fetch('_shards').fetch('total')
    successful = refresh_result.fetch('_shards').fetch('successful')

    if search_result_size == 0
      puts "ERROR BLYAD; search_result_size is EQ 0"
    end

    if total != successful
      puts "ANOTHER ERROR BLYEAD; total: #{total}, successful: #{successful}"
    end
  end

  def insert(body)
    @client.index(params.merge(body: body))
  end

  def refresh
    @client.indices.refresh(index: INDEX)
  end

  def search(user_id)
    @client.search(params.merge(body: {query: {match: {user_id: user_id}}}))
  end

private

  def params
    {index: INDEX, type: TYPE}
  end

  def generate_message
    {
      user_id: SecureRandom.uuid,
      owner:   FFaker::Name.name,
      text:    FFaker::HipsterIpsum.words(42).join(' '),
      date:    DateTime.now
    }
  end
end

client = Elasticsearch::Client.new(url: 'http://188.166.26.174:9200')

# RefreshTest.new(client).action!

10_000.times do
  Thread.new { RefreshTest.new(client).action! }.join
end
