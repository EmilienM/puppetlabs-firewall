require 'spec_helper_acceptance'

# iptables version 1.3.5 is not suppored by the ip6tables provider
describe 'firewall bridging', unless: (os[:family] == 'redhat' && os[:release].start_with?('5')) do
  before :all do
    iptables_flush_all_tables
    ip6tables_flush_all_tables
  end
  describe 'ip6tables physdev tests' do
    context 'when physdev_in eth0' do
      pp8 = <<-PUPPETCODE
              class { '::firewall': }
              firewall { '701 - test':
                provider => 'ip6tables',
                chain => 'FORWARD',
                proto  => tcp,
                port   => '701',
                action => accept,
                physdev_in => 'eth0',
              }
        PUPPETCODE
      it 'applies' do
        apply_manifest(pp8, catch_failures: true)
        apply_manifest(pp8, catch_changes: do_catch_changes)
      end

      it 'contains the rule' do
        shell('ip6tables-save') do |r|
          expect(r.stdout).to match(%r{-A FORWARD -p tcp -m physdev\s+--physdev-in eth0 -m multiport --ports 701 -m comment --comment "701 - test" -j ACCEPT})
        end
      end
    end

    context 'when physdev_out eth1' do
      pp9 = <<-PUPPETCODE
              class { '::firewall': }
              firewall { '702 - test':
                provider => 'ip6tables',
                chain => 'FORWARD',
                proto  => tcp,
                port   => '702',
                action => accept,
                physdev_out => 'eth1',
              }
        PUPPETCODE
      it 'applies' do
        apply_manifest(pp9, catch_failures: true)
        apply_manifest(pp9, catch_changes: do_catch_changes)
      end

      it 'contains the rule' do
        shell('ip6tables-save') do |r|
          expect(r.stdout).to match(%r{-A FORWARD -p tcp -m physdev\s+--physdev-out eth1 -m multiport --ports 702 -m comment --comment "702 - test" -j ACCEPT})
        end
      end
    end

    context 'when physdev_in eth0 and physdev_out eth1' do
      pp10 = <<-PUPPETCODE
              class { '::firewall': }
              firewall { '703 - test':
                provider => 'ip6tables',
                chain => 'FORWARD',
                proto  => tcp,
                port   => '703',
                action => accept,
                physdev_in => 'eth0',
                physdev_out => 'eth1',
              }
        PUPPETCODE
      it 'applies' do
        apply_manifest(pp10, catch_failures: true)
        apply_manifest(pp10, catch_changes: do_catch_changes)
      end

      it 'contains the rule' do
        shell('ip6tables-save') do |r|
          expect(r.stdout).to match(%r{-A FORWARD -p tcp -m physdev\s+--physdev-in eth0 --physdev-out eth1 -m multiport --ports 703 -m comment --comment "703 - test" -j ACCEPT})
        end
      end
    end

    context 'when physdev_is_bridged' do
      pp11 = <<-PUPPETCODE
              class { '::firewall': }
              firewall { '704 - test':
                provider => 'ip6tables',
                chain => 'FORWARD',
                proto  => tcp,
                port   => '704',
                action => accept,
                physdev_is_bridged => true,
              }
        PUPPETCODE
      it 'applies' do
        apply_manifest(pp11, catch_failures: true)
        apply_manifest(pp11, catch_changes: do_catch_changes)
      end

      it 'contains the rule' do
        shell('ip6tables-save') do |r|
          expect(r.stdout).to match(%r{-A FORWARD -p tcp -m physdev\s+--physdev-is-bridged -m multiport --ports 704 -m comment --comment "704 - test" -j ACCEPT})
        end
      end
    end

    context 'when physdev_in eth0 and physdev_is_bridged' do
      pp12 = <<-PUPPETCODE
              class { '::firewall': }
              firewall { '705 - test':
                provider => 'ip6tables',
                chain => 'FORWARD',
                proto  => tcp,
                port   => '705',
                action => accept,
                physdev_in => 'eth0',
                physdev_is_bridged => true,
              }
        PUPPETCODE
      it 'applies' do
        apply_manifest(pp12, catch_failures: true)
        apply_manifest(pp12, catch_changes: do_catch_changes)
      end

      it 'contains the rule' do
        shell('ip6tables-save') do |r|
          expect(r.stdout).to match(%r{-A FORWARD -p tcp -m physdev\s+--physdev-in eth0 --physdev-is-bridged -m multiport --ports 705 -m comment --comment "705 - test" -j ACCEPT})
        end
      end
    end

    context 'when physdev_out eth1 and physdev_is_bridged' do
      pp13 = <<-PUPPETCODE
              class { '::firewall': }
              firewall { '706 - test':
                provider => 'ip6tables',
                chain => 'FORWARD',
                proto  => tcp,
                port   => '706',
                action => accept,
                physdev_out => 'eth1',
                physdev_is_bridged => true,
              }
        PUPPETCODE
      it 'applies' do
        apply_manifest(pp13, catch_failures: true)
        apply_manifest(pp13, catch_changes: do_catch_changes)
      end

      it 'contains the rule' do
        shell('ip6tables-save') do |r|
          expect(r.stdout).to match(%r{-A FORWARD -p tcp -m physdev\s+--physdev-out eth1 --physdev-is-bridged -m multiport --ports 706 -m comment --comment "706 - test" -j ACCEPT})
        end
      end
    end

    context 'when physdev_in eth0 and physdev_out eth1 and physdev_is_bridged' do
      pp14 = <<-PUPPETCODE
              class { '::firewall': }
              firewall { '707 - test':
                provider => 'ip6tables',
                chain => 'FORWARD',
                proto  => tcp,
                port   => '707',
                action => accept,
                physdev_in => 'eth0',
                physdev_out => 'eth1',
                physdev_is_bridged => true,
              }
        PUPPETCODE
      it 'applies' do
        apply_manifest(pp14, catch_failures: true)
        apply_manifest(pp14, catch_changes: do_catch_changes)
      end

      it 'contains the rule' do
        shell('ip6tables-save') do |r|
          expect(r.stdout).to match(%r{-A FORWARD -p tcp -m physdev\s+--physdev-in eth0 --physdev-out eth1 --physdev-is-bridged -m multiport --ports 707 -m comment --comment "707 - test" -j ACCEPT})
        end
      end
    end

    context 'when physdev_is_in' do
      pp15 = <<-PUPPETCODE
          class { '::firewall': }
          firewall { '708 - test':
            provider => 'ip6tables',
            chain => 'FORWARD',
            proto  => tcp,
            port   => '708',
            action => accept,
            physdev_is_in => true,
          }
        PUPPETCODE
      it 'applies' do
        apply_manifest(pp15, catch_failures: true)
        apply_manifest(pp15, catch_changes: do_catch_changes)
      end

      it 'contains the rule' do
        shell('ip6tables-save') do |r|
          expect(r.stdout).to match(%r{-A FORWARD -p tcp -m physdev\s+--physdev-is-in -m multiport --ports 708 -m comment --comment "708 - test" -j ACCEPT})
        end
      end
    end

    context 'when physdev_is_out' do
      pp16 = <<-PUPPETCODE
          class { '::firewall': }
          firewall { '709 - test':
            provider => 'ip6tables',
            chain => 'FORWARD',
            proto  => tcp,
            port   => '709',
            action => accept,
            physdev_is_out => true,
          }
        PUPPETCODE
      it 'applies' do
        apply_manifest(pp16, catch_failures: true)
        apply_manifest(pp16, catch_changes: do_catch_changes)
      end

      it 'contains the rule' do
        shell('ip6tables-save') do |r|
          expect(r.stdout).to match(%r{-A FORWARD -p tcp -m physdev\s+--physdev-is-out -m multiport --ports 709 -m comment --comment "709 - test" -j ACCEPT})
        end
      end
    end
  end
end
