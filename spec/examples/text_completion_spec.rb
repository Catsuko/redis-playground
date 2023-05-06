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

    it 'removes the delimiter from terms if present' do
      completion.notice(text + ':')
      expect(completion.suggest(text)).to contain_exactly(text)
    end

    it 'does not suggest searches with less than 3 characters' do
      completion.notice('a').notice(' a ').notice('a             a')
      expect(completion.suggest('a')).to match []
    end

    it 'purges an older suggestion when noticing new terms' do
      old_suggestions = %w(apple adam ample arbiter after artsy adder another assume augment)
      old_suggestions.each { |t| completion.notice(t) }
      completion.notice('bambi')
      suggestions = completion.suggest('a')
      expect(suggestions.size).to eq old_suggestions.size - 1
      expect(suggestions.all? { |s| old_suggestions.include?(s) }).to be true
    end

    it 'does not purge older popular suggestions' do
      2.times { completion.notice(text) }
      always_purge_completion = described_class.new(redis, key: 'test_completion', purge_threshold: 1)
      always_purge_completion.notice('cat')
      expect(always_purge_completion.suggest(text)).to contain_exactly(text)
    end

  end

end
