require 'text_completion'

RSpec.describe TextCompletion do

  describe '#suggest' do

    let(:text) { 'dog' }
    let(:completion) { described_class.new(redis, key: 'test_completion') }
    subject { completion.suggest(text) }

    it 'has no suggestions when no previous searches were noticed' do
      is_expected.to match []
    end

    it 'returns similar terms that were previously noticed' do
      completion.notice('cat').notice('mouse').notice('deer')
      similar_terms = %w(doggy doge dogger dogod)
      similar_terms.each { |t| completion.notice(t) }
      is_expected.to match_array similar_terms
    end

    it 'returns the most similar term when limited' do
      similar_terms = %w(doge doggy doggg)
      similar_terms.each { |t| completion.notice(t) }
      expect(completion.suggest(text, limit: 1)).to contain_exactly(similar_terms.first)
    end

  end

end
