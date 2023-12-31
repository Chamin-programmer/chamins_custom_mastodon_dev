# frozen_string_literal: true

module BrandingHelper
  def logo_as_symbol(version = :icon)
    case version
    when :icon
      _logo_as_symbol_icon
    when :wordmark
      _logo_as_symbol_wordmark
    end
  end

  def _logo_as_symbol_wordmark
    image_pack_tag('logo_wordmark.png', class: 'logo logo--wordmark', height: '24px')
  end

  def _logo_as_symbol_icon
    content_tag(:svg, tag.use(href: '#logo-symbol-icon'), viewBox: '0 0 79 79', class: 'logo logo--icon')
  end

  def render_logo
    image_pack_tag('logo_icon.png', alt: 'Mastodon', class: 'logo logo--icon')
  end

  def render_symbol(version = :icon)
    path = case version
           when :icon
             'logo-symbol-icon.svg'
           when :wordmark
             'logo-symbol-wordmark.svg'
           end

    render(file: Rails.root.join('app', 'javascript', 'images', path)).html_safe # rubocop:disable Rails/OutputSafety
  end
end
