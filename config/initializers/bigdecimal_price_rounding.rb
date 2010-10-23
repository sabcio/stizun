
# Allows us to round prices in a price-friendly way, e.g. to 0.05 precision
# for Switzerland, Finland and other nations without 0.01 and 0.02 coins.
class BigDecimal
  def rounded(divider = 5)
    return (self/BigDecimal("#{divider}")).round(2, BigDecimal::ROUND_UP) * BigDecimal("#{divider}")  
  end
end