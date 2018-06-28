require 'spec_helper_acceptance'

RSpec.context 'ssh_authorized_key: Query' do
  let(:auth_keys) { '~/.ssh/authorized_keys' }
  let(:name) { "pl#{rand(999_999).to_i}" }

  before do
    posix_agents.each do |agent|
      on(agent, "cp #{auth_keys} /tmp/auth_keys", acceptable_exit_codes: [0, 1])
      on(agent, "echo '' >> #{auth_keys} && echo 'ssh-rsa mykey #{name}' >> #{auth_keys}")
    end
  end

  after do
    posix_agents.each do |agent|
      # (teardown) restore the #{auth_keys} file
      on(agent, "mv /tmp/auth_keys #{auth_keys}", acceptable_exit_codes: [0, 1])
    end
  end

  posix_agents.each do |agent|
    it "#{agent} should be able to find an existing SSH authorized key", pending: 'Blocked by PUP-1605' do
      on(agent, puppet_resource('ssh_authorized_key', "/#{name}")) do |_res|
        expect(stdout).to include(name.to_s)
      end
    end
  end
end
