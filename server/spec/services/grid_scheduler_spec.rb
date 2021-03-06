require_relative '../spec_helper'

describe GridScheduler do

  let(:grid) { Grid.create!(name: 'test-grid') }
  let(:grid_service) { GridService.create!(image_name: 'kontena/redis:2.8', name: 'redis', grid: grid) }
  let(:nodes) do
    nodes = []
    3.times { nodes << HostNode.create!(node_id: SecureRandom.uuid) }
    nodes
  end
  let(:strategy) { Scheduler::Strategy::HighAvailability.new }
  let(:subject) { described_class.new(strategy) }

  describe '#select_node' do
    it 'filters nodes' do
      expect(subject).to receive(:filter_nodes).once.with(grid_service, 'foo-1', nodes).and_return(nodes)
      subject.select_node(grid_service, 'foo-1', nodes)
    end

    it 'returns a node' do
      node = subject.select_node(grid_service, 'foo-1', nodes)
      expect(nodes.include?(node)).to eq(true)
    end
  end

  describe '#filter_nodes' do
    it 'filters every node' do
      subject.filters.each do |filter|
        expect(filter).to receive(:for_service).once.with(grid_service, 'foo-1', anything)
      end
      subject.filter_nodes(grid_service, 'foo-1', nodes)
    end
  end
end
