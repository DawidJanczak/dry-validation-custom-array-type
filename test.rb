# frozen_string_literal: true

require 'json'
require 'dry-types'
require 'dry-validation'

module Types
  include Dry.Types()

  DatastoreArrayBlob = Array.constructor { |input| ::JSON.parse(input.string) }
end

class MyContract < Dry::Validation::Contract
  json do
    required(:items).value(Types::DatastoreArrayBlob).each do
      hash do
        required(:code).filled(:string)
      end
    end
  end
end

items = StringIO.new(JSON.generate([{ code: 'ABC' }, { code: 'DEF' }]))

p MyContract.new.call(items: items) # => #<Dry::Validation::Result{:items=>[{}, {}]} errors={:items=>{0=>{:code=>["is missing"]}, 1=>{:code=>["is missing"]}}}>

# If I comment out .each block and run validation on that I see items filled,
# unlike the above case:
#
# p MyContract.new.call(items: items) => #<Dry::Validation::Result{:items=>[{"code"=>"ABC"}, {"code"=>"DEF"}]} errors={}>
#
# So I think it's something to do with .each, but am not sure what exactly.
