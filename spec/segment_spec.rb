require 'spec_helper'

RSpec.describe Aws::Xray::Segment do
  let(:trace) { Aws::Xray::Trace.new(root: '1-67891233-abcdef012345678912345678', parent: 'd5058bbe22392c37', sampled: true) }

  describe 'serialization' do
    it 'serialized properly' do
      segment = described_class.build('test-app', trace)
      expect(segment.to_h).to match(
        name: 'test-app',
        id: /\A[0-9A-Fa-f]{16}\z/,
        trace_id: '1-67891233-abcdef012345678912345678',
        service: { version: 'deadbeef' },
        annotations: a_kind_of(Hash),
        metadata: a_kind_of(Hash),
        start_time: a_kind_of(Float),
        in_progress: true,
        parent_id: 'd5058bbe22392c37',
      )
      segment.finish
      expect(segment.to_h.has_key?(:in_progress)).to eq(false)
      expect(segment.to_h.has_key?(:end_time)).to eq(true)

      SegmentValidator.call(segment.to_json)
    end

    it 'supports user field' do
      segment = described_class.build('test-app', trace)
      segment.user = 'example'
      expect(segment.to_h).to include(user: 'example')
    end
  end

  describe '#add_annotation' do
    it 'sets annotation' do
      segment = described_class.build('test-app', trace)
      segment.add_annotation(server: 'web-001')
      expect(segment.to_h[:annotations][:server]).to eq('web-001')
    end
  end

  describe '#add_metadata' do
    it 'sets metadata' do
      segment = described_class.build('test-app', trace)
      segment.add_metadata(server: 'web-001')
      expect(segment.to_h[:metadata][:server]).to eq('web-001')
    end
  end
end
