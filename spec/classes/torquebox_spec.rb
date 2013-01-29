#!/usr/bin/env rspec
require 'spec_helper'

describe 'torquebox' do
  let(:facts) { { :osfamily => 'Debian' } }

  it { should include_class('torquebox::java') }

  describe 'use_latest parameter' do
    it { should contain_package('openjdk-6-jre-headless').with_ensure('present') }

    describe 'set to true' do
      let(:params) { { :use_latest => true } }

      it { should contain_package('openjdk-6-jre-headless').with_ensure('latest') }
    end

    describe 'set to false' do
      let(:params) { { :use_latest => false } }

      it { should contain_package('openjdk-6-jre-headless').with_ensure('present') }
    end

    describe 'set to a non-boolean' do
      let(:params) { { :use_latest => 'string' } }

      it { expect{ subject }.to raise_error(/^The use_latest parameter must be either true or false\./) }
    end
  end

  describe 'for unsupported operating system families' do
    let(:facts) { { :osfamily  => 'Unsupported' } }

    it { expect{ subject }.to raise_error(/^The torquebox module is not supported on Unsupported based systems/)}
  end
end
