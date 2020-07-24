# frozen_string_literal: true

require 'rails_helper'
require './lib/tasks/support/schema_camelizer.rb'

describe SchemaCamelizer do
  TEST_DIRECTORY = 'tmp/camel_schema_tests'
  TEST_SCHEMA_DIRECTORY = TEST_DIRECTORY + '/schemas'
  TEST_RESULT_DIRECTORY = TEST_DIRECTORY + '/schemas_camelized'

  before(:context) do
    # create directories for source and result schemas
    FileUtils.mkdir_p(TEST_SCHEMA_DIRECTORY)
    FileUtils.mkdir_p(TEST_RESULT_DIRECTORY)
  end

  after(:context) do
    FileUtils.remove_dir(TEST_DIRECTORY)
  end

  def create_source_schema(name, hash)
    schema_file = "#{TEST_SCHEMA_DIRECTORY}/#{name}.json"
    File.open(schema_file, 'w') { |file| file.write(JSON.pretty_generate(hash)) }
    schema_file
  end

  describe '#camel_schema' do
    it 'should camel-inflect keys' do
      schema = {'cat_sound' => 'meow', 'dog_sound' => 'woof'}
      filename = create_source_schema('basic_inflect', schema)
      subject = SchemaCamelizer.new(filename)
      expect(subject.camel_schema.keys).to match %w(catSound dogSound)
    end
    it 'should camel-inflect nested keys'
    it 'should camel-inflect values in "required" keys'
  end

  describe '#referenced_schemas' do
    it 'should be empty with no references'
    it 'should be an Array of SchemaCamelizers for referenced schemas'
  end

  describe '#already_camelized' do
    it 'when the source schema has camel keys it should be true'
    it 'when the source schema has snake keys it should be false'
  end

  describe '#camel_path' do
    it 'should be in schemas_camelized directory'
  end

  describe '#unchanged_schemas' do
    it 'should be an array of names of schemas that are already_camelized'
    it 'should be empty if the original schema was snake case'
  end

  describe '#save!' do
    it 'should write a file to the disk'
    it 'should return an array of paths to saved files'
  end
end