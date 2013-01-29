#!/usr/bin/env rspec
require 'spec_helper'

describe 'torquebox::java' do
  let(:facts) { { :osfamily => 'Debian' } }

  describe 'supports adjusting OpenJDK version' do
    let(:params) { { :openjdk_version => 7 } }

    it { should contain_package('openjdk-7-jre-headless').with_ensure('present') }
  end

  describe 'supports adjusting OpenJDK variant' do
    describe 'to Zero' do
      let(:params) { { :openjdk_variant => 'zero' } }

      it { should contain_package('openjdk-6-jre-zero').with_ensure('present') }
    end

    describe 'to base (no specific variant)' do
      let(:params) { { :openjdk_variant => '' } }

      it { should contain_package('openjdk-6-jre').with_ensure('present') }
    end
  end

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

    it { expect{ subject }.to raise_error(/^The torquebox::java module is not supported on Unsupported based systems/)}
  end
end
