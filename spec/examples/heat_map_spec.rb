require 'heat_map'

RSpec.describe HeatMap do

  let(:heat_map) { described_class.new(redis) }

  describe '#size_of' do
    let(:area) { 'australia' }
    subject { heat_map.size_of(area) }

    context 'when nothing has been noticed' do
      it 'returns zero for a single area' do
        is_expected.to be_zero
      end

      it 'returns zero for multiple areas' do
        expect(heat_map.size_of('australia', 'peru')).to be_zero
      end
    end

    it 'returns the unique size between multiple areas' do
      heat_map.notice(area, item: 1).notice('peru', item: 1).notice('russia', item: 1)
      expect(heat_map.size_of(area, 'peru', 'russia')).to eq 1
    end

    it 'does not increase size when same item is noticed multiple times' do
      3.times { heat_map.notice(area, item: 1) }
      is_expected.to eq 1
    end

    it 'increases size when multiple items are noticed' do
      3.times { |n| heat_map.notice(area, item: n) }
      is_expected.to eq 3
    end
  end

  describe '#clear' do
    let(:area) { 'peru' }
    subject { heat_map.clear(area) }

    it 'brings size back to 0 for the provided area' do
      heat_map.notice(area, item: 1)
      expect { subject }.to change { heat_map.size_of(area) }.from(1).to(0)
    end
  end

end
