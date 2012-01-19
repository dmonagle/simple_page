module SimplePageExtension
    def page(number)
        return nil if number.nil?
        offset = (number.to_i - 1) * page_size
        return nil if offset < 0
        self.offset(offset).limit(page_size)
    end
    
    def page_count
        return @page_count unless @page_count.nil?
        c = (self.count / Float(page_size)).ceil
        @page_count = c == 0 ? 1 : c
        @page_count
    end
    
    def page_size
        @page_size || 10
    end
    
    def page_size=(size)
        @page_size = size
        @page_size = size == 0 ? nil : size
    end

    def find_page_number(reference)
      count = 0
      self.each do |o|
        count += 1
        if o.id == reference.id
          return (count / Float(page_size)).ceil
        end
      end
    end
    
    def page_links_generator(page, options)
      raise ArgumentError, "No window block supplied." unless block_given?
      raise ArgumentError, "please specify a :inner option" unless inner = options[:inner]
      return if self.page_count < 2
      outer = options[:outer] || 0
      extras = [ options[:extras] ].flatten.compact
      page_number = page.to_i
      last_page = self.page_count
      next_page = page_number >= self.page_count ? nil : page_number + 1
      prev_page = page_number > 1 ? page_number - 1 : nil
      numbers = case
      when page_number <= inner + 1
        1 .. 1 + 2 * inner
      when page_number >= self.page_count - inner
        self.page_count - 2 * inner .. self.page_count
      else
        page_number - inner .. page_number + inner
      end.to_a
      1.upto(outer) { |n| numbers << n << self.page_count-n+1 }
      numbers.uniq!
      numbers.sort!
      numbers.reject! { |number| !number.between?(1, self.page_count) }
      [].tap do |results|
        results << yield(:first, 1, []) if extras.include?(:first)
        results << yield(:previous, prev_page, []) if extras.include?(:previous)
        numbers.zip([nil]+numbers, numbers[1..-1]) do |number, prev_number, next_number|
          classes = []
          classes << :selected if page_number == number
          classes << :gap_before if prev_number && prev_number < number - 1
          classes << :gap_after  if next_number && next_number > number + 1
          results << yield(number, number, classes)
        end        
        results << yield(:next, next_page, []) if extras.include?(:next)
        results << yield(:last, self.page_count, []) if extras.include?(:last)
      end.join("\n").html_safe
    end
end
