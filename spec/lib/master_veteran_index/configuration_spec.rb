# frozen_string_literal: true

require 'rails_helper'
require 'master_veteran_index/service'

describe MasterVeteranIndex::Configuration do
  describe '.ssl_options' do
    context 'when there are no SSL options' do
      before do
        allow(MasterVeteranIndex::Configuration.instance).to receive(:ssl_cert).and_return(nil)
        allow(MasterVeteranIndex::Configuration.instance).to receive(:ssl_key).and_return(nil)
      end

      it 'returns nil' do
        allow(MasterVeteranIndex::Configuration.instance).to receive(:ssl_cert).and_return(nil)
        allow(MasterVeteranIndex::Configuration.instance).to receive(:ssl_key).and_return(nil)
        expect(MasterVeteranIndex::Configuration.instance.ssl_options).to be_nil
      end
    end

    context 'when there are SSL options' do
      let(:cert) { instance_double('OpenSSL::X509::Certificate') }
      let(:key) { instance_double('OpenSSL::PKey::RSA') }

      before do
        allow(MasterVeteranIndex::Configuration.instance).to receive(:ssl_cert) { cert }
        allow(MasterVeteranIndex::Configuration.instance).to receive(:ssl_key) { key }
      end

      it 'returns the wsdl, cert and key paths' do
        expect(MasterVeteranIndex::Configuration.instance.ssl_options).to eq(
          client_cert: cert,
          client_key: key
        )
      end
    end
  end

  describe '.open_timeout' do
    context 'when Settings.mvi.open_timeout is set' do
      it 'uses the setting' do
        expect(MasterVeteranIndex::Configuration.instance.open_timeout).to eq(15)
      end
    end
  end

  describe '.read_timeout' do
    context 'when Settings.mvi.timeout is set' do
      it 'uses the setting' do
        expect(MasterVeteranIndex::Configuration.instance.read_timeout).to eq(30)
      end
    end
  end
end