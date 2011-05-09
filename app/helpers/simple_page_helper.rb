module SimplePageHelper
  def simple_page_marker(page)
    case page
        when :previous 
            return "Previous"
        when :next
            return "Next"
        when :first 
            return "First"
        when :last
            return "Last"
        else
            return page
    end
  end

  def page_links(collection, selected_page, extras = [ :previous, :next ], page_tag_helper = lambda {|page| simple_page_marker(page)})
    content_tag :ul, :class => "page_select" do
      collection.page_links_generator(selected_page, :inner => 2, :outer => 1, :extras => extras) do |tag, page_number, classes|
        content_tag :li, link_to(page_tag_helper.call(tag), params.merge(:page => page_number)), :class => (classes << :page).join(" ")
      end
    end
  end
end