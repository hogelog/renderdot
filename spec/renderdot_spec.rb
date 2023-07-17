# frozen_string_literal: true

RSpec.describe Renderdot do
  let(:dot) { "digraph { a -> b }" }

  describe "#render_html" do
    it do
      html = Renderdot.render_html(dot)
      expect(html).to start_with("<html")
    end
  end
end
