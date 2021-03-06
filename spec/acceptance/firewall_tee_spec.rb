require 'spec_helper_acceptance'

describe 'firewall tee', unless: (os[:family] == 'redhat' && os[:release].start_with?('5', '6')) || (os[:family] == 'sles') do
  before :all do
    iptables_flush_all_tables
    ip6tables_flush_all_tables
  end
  describe 'tee_gateway' do
    context 'when 10.0.0.2' do
      pp1 = <<-PUPPETCODE
          class { '::firewall': }
          firewall {
            '810 - tee_gateway':
              chain   => 'PREROUTING',
              table   => 'mangle',
              jump    => 'TEE',
              gateway => '10.0.0.2',
              proto   => all,
          }
      PUPPETCODE
      it 'applies' do
        apply_manifest(pp1, catch_failures: true)
      end

      it 'contains the rule' do
        shell('iptables-save -t mangle') do |r|
          expect(r.stdout).to match(%r{-A PREROUTING -m comment --comment "810 - tee_gateway" -j TEE --gateway 10.0.0.2})
        end
      end
    end
  end

  describe 'tee_gateway6' do
    context 'when 2001:db8::1' do
      pp2 = <<-PUPPETCODE
          class { '::firewall': }
          firewall {
            '811 - tee_gateway6':
              chain    => 'PREROUTING',
              table    => 'mangle',
              jump     => 'TEE',
              gateway  => '2001:db8::1',
              proto   => all,
              provider => 'ip6tables',
          }
      PUPPETCODE
      it 'applies' do
        apply_manifest(pp2, catch_failures: true)
      end

      it 'contains the rule' do
        shell('ip6tables-save -t mangle') do |r|
          expect(r.stdout).to match(%r{-A PREROUTING -m comment --comment "811 - tee_gateway6" -j TEE --gateway 2001:db8::1})
        end
      end
    end
  end
end
