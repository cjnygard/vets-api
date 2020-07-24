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

    raise "test is reusing #{name} for source schema filename" if File.exist?(schema_file)

    File.open(schema_file, 'w') { |file| file.write(JSON.pretty_generate(hash)) }
    schema_file
  end

  describe '#camel_schema' do
    it 'camel-inflects keys' do
      schema = { 'cat_sound' => 'meow', 'dog_sound' => 'woof' }
      filename = create_source_schema('basic', schema)
      subject = SchemaCamelizer.new(filename)
      expect(subject.camel_schema.keys).to match %w[catSound dogSound]
    end
    it 'camel-inflects nested keys' do
      schema = { 'cat' => { 'mouth_sound' => 'meow', 'leg_count' => 4 } }
      filename = create_source_schema('nested_keys', schema)
      subject = SchemaCamelizer.new(filename)
      expect(subject.camel_schema['cat'].keys).to match %w[mouthSound legCount]
    end
    it 'camel-inflects values in "required" keys' do
      schema = { 'required' => %w[animal_sounds animal_names animal_outfits] }
      filename = create_source_schema('required_keys', schema)
      subject = SchemaCamelizer.new(filename)
      expect(subject.camel_schema['required']).to match %w[animalSounds animalNames animalOutfits]
    end
  end

  describe '#referenced_schemas' do
    it 'is empty with no references' do
      schema = { 'refer_to' => 'nothing' }
      filename = create_source_schema('no_references', schema)
      subject = SchemaCamelizer.new(filename)
      expect(subject.referenced_schemas).to be_empty
    end
    it 'is an Array of SchemaCamelizers for referenced schemas' do
      referenced_schema = { 'refer_to' => 'me' }
      referenced_schema_name = 'refer_to_me'
      referenced_filename = create_source_schema(referenced_schema_name, referenced_schema)

      schema = { 'refer_to' => 'something', '$ref' => referenced_filename.gsub(TEST_SCHEMA_DIRECTORY + '/', '') }
      filename = create_source_schema('references', schema)
      subject = SchemaCamelizer.new(filename)
      expect(subject.referenced_schemas.count).to eq 1
      expect(subject.referenced_schemas.first).to be_a SchemaCamelizer
      expect(subject.referenced_schemas.first.name).to eq referenced_schema_name
    end
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
