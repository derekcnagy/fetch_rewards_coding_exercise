require 'page-object'

class ScalesPage
  include PageObject

  URL = 'http://ec2-54-208-152-154.compute-1.amazonaws.com/'

  text_fields(:left_bowl_spots, xpath: "//div[@class='game-board']//input[@data-side='left']")
  text_fields(:right_bowl_spots, xpath: "//div[@class='game-board']//input[@data-side='right']")
  button(:reset, xpath: "//button[@id='weigh']/../button[@id='reset']")
  button(:weigh, id: 'weigh')
  buttons(:gold_bars, xpath: "//div[@class='coins']/button")
  list_items(:weighings, xpath: "//div[@class='game-info']/ol/li")

  def visit
    @browser.goto URL
  end

  def weigh_bars(left, right)
    self.reset
    left.each_with_index do |bar, index|
      self.left_bowl_spots_elements[index].set bar
    end

    right.each_with_index do |bar, index|
      self.right_bowl_spots_elements[index].set bar
    end

    weighings_counts = self.weighings_elements.size
    self.weigh
    timeout = 5
    until (self.weighings_elements.size > weighings_counts) or timeout < 0
      sleep 1
      timeout -= 1
    end
    self.weighings_elements.last.text[/[<>=]/]
  end

  def select_bar(fake_bar)
    self.gold_bars_elements.each do |bar|
      if bar.text.strip.eql? fake_bar.strip
        bar.click
        break
      end
    end
  end

  def find_fake_gold_bar
    possible_fake_bars = self.gold_bars_elements.collect { |gold_bar| gold_bar.text }
    remainder = possible_fake_bars.pop if possible_fake_bars.size.odd?

    until possible_fake_bars.size.eql? 1
      number_for_each_bowl = possible_fake_bars.size / 2
      left_bowl = possible_fake_bars.pop(number_for_each_bowl)
      right_bowl = possible_fake_bars.pop(number_for_each_bowl)

      result = self.weigh_bars left_bowl, right_bowl

      case result
      when '='
        return remainder
      when '<'
        possible_fake_bars = left_bowl
      when '>'
        possible_fake_bars = right_bowl
      end
    end
    possible_fake_bars.first
  end
end
