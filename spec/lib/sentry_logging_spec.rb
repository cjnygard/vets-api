# frozen_string_literal: true

require 'rails_helper'
require 'sentry_logging'

shared_examples 'a sentry logger' do
  subject { class_instance }

  let(:class_instance) { described_class.new }
  let(:exception) { StandardError.new }

  context 'with SENTRY_DSN set' do
    before { Settings.sentry.dsn = 'sentry' }

    after { Settings.sentry.dsn = nil }

    describe '#log_message_to_sentry' do
      it 'sends the message and log level to the Rails logger' do
        allow(Rails.logger).to receive(:info)

        subject.log_message_to_sentry('message', :info)

        expect(Rails.logger).to have_received(:info).with('message')
      end

      it 'concats and formats the extra_context with the message if it exists' do
        allow(Rails.logger).to receive(:warn)

        subject.log_message_to_sentry('message', :warn, some_extra_context: { a_context: 'as an example' })

        expect(Rails.logger).to have_received(:warn).with('message : {:some_extra_context=>{:a_context=>"as an example"}}')
      end

      it 'sends the message and log level to Sentry' do
        allow(Raven).to receive(:capture_message)

        subject.log_message_to_sentry('message', :debug)

        expect(Raven).to have_received(:capture_message).with('message', level: 'debug')
      end

      it 'sets the extra_context for Sentry if it exists' do
        allow(Raven).to receive(:capture_message)
        allow(Raven).to receive(:extra_context)
        allow(Raven).to receive(:tags_context)

        subject.log_message_to_sentry('message', :debug, some_extra_context: { a_context: 'as an example' })

        expect(Raven).to have_received(:capture_message).with('message', level: 'debug')
        expect(Raven).to have_received(:extra_context).with({:some_extra_context=>{:a_context=>"as an example"}})
        expect(Raven).not_to have_received(:tags_context)
      end

      it 'sets the tags_context for Sentry if it exists' do
        allow(Raven).to receive(:capture_message)
        allow(Raven).to receive(:extra_context)
        allow(Raven).to receive(:tags_context)

        subject.log_message_to_sentry('message', :debug, {}, { feature: 'a feature tag' })

        expect(Raven).to have_received(:capture_message).with('message', level: 'debug')
        expect(Raven).to have_received(:tags_context).with({:feature=>"a feature tag"})
        expect(Raven).not_to have_received(:extra_context)
      end
    end

    describe '#log_exception_to_sentry' do
      it 'warn logs to Rails logger' do
        expect(Rails.logger).to receive(:error).with(exception.message + '.')
        subject.log_exception_to_sentry(exception)
      end
      it 'logs to Sentry' do
        expect(Raven).to receive(:capture_exception).with(exception, level: 'error').once
        subject.log_exception_to_sentry(exception)
      end
    end
  end

  context 'without SENTRY_DSN set' do
    describe '#log_message_to_sentry' do
      it 'warn logs to Rails logger' do
        expect(Rails.logger).to receive(:warn).with(/blah/).with(/context/)
        subject.log_message_to_sentry('blah', :warn, { extra: 'context' }, tags: 'tagging')
      end
      it 'does not log to Sentry' do
        expect(Raven).to receive(:capture_exception).exactly(0).times
        subject.log_message_to_sentry('blah', :warn, { extra: 'context' }, tags: 'tagging')
      end
    end

    describe '#log_exception_to_sentry' do
      it 'error logs to Rails logger' do
        expect(Rails.logger).to receive(:error).with(exception.message + '.')
        subject.log_exception_to_sentry(exception)
      end
      it 'does not log to Sentry' do
        expect(Raven).to receive(:capture_exception).exactly(0).times
        subject.log_exception_to_sentry(exception)
      end
    end
  end
end

class Foo
  include SentryLogging
end
RSpec.describe Foo do
  it_behaves_like 'a sentry logger'
end
