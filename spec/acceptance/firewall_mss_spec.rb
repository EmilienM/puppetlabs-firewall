require 'spec_helper_acceptance'

describe 'firewall MSS', unless: os[:family] == 'redhat' && os[:release].start_with?('5') do
  before :all do
    iptables_flush_all_tables
    ip6tables_flush_all_tables
  end

  describe 'mss ipv6 tests' do
    context 'when 1360' do
      pp3 = <<-PUPPETCODE
            class { '::firewall': }
            firewall {
              '502 - set_mss':
                proto     => 'tcp',
                tcp_flags => 'SYN,RST SYN',
                jump      => 'TCPMSS',
                set_mss   => '1360',
                mss       => '1361:1541',
                chain     => 'FORWARD',
                table     => 'mangle',
                provider  => 'ip6tables',
            }
        PUPPETCODE
      it 'applies' do
        apply_manifest(pp3, catch_failures: true)
      end

      it 'contains the rule' do
        shell('ip6tables-save -t mangle') do |r|
          expect(r.stdout).to match(%r{-A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1541 -m comment --comment "502 - set_mss" -j TCPMSS --set-mss 1360})
        end
      end
    end

    context 'when clamp_mss_to_pmtu' do
      pp4 = <<-PUPPETCODE
            class { '::firewall': }
            firewall {
              '503 - clamp_mss_to_pmtu':
                proto             => 'tcp',
                chain             => 'FORWARD',
                tcp_flags         => 'SYN,RST SYN',
                jump              => 'TCPMSS',
                clamp_mss_to_pmtu => true,
                provider          => 'ip6tables',
            }
        PUPPETCODE
      it 'applies' do
        apply_manifest(pp4, catch_failures: true)
      end

      it 'contains the rule' do
        shell('ip6tables-save') do |r|
          expect(r.stdout).to match(%r{-A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -m comment --comment "503 - clamp_mss_to_pmtu" -j TCPMSS --clamp-mss-to-pmtu})
        end
      end
    end
  end
end
