Given /^a category named "([^\"]*)" exists$/ do |arg1|
  @category = Category.find_or_create_by_name(:name => arg1)
end

When /^I view the product list$/ do
  visit products_path
end

When /^I view the category "([^\"]*)"$/ do |arg1|
  visit products_path
  click_link arg1
end

Then /^I should not see a product named "([^\"]*)"$/ do |arg1|
  page.should_not have_content(arg1)
end

Then /^I should see a product named "([^\"]*)"$/ do |arg1|
  page.should have_content(arg1)
end

Then /^there should be a product called "([^\"]*)"$/ do |arg1|
  @prod = Product.where(:name => arg1).first
  @prod.should_not == nil
end

Then /^there should not be a product called "([^\"]*)"$/ do |arg1|
  @prod = Product.where(:name => arg1).first
  @prod.should == nil
end

Then /^the category "([^\"]*)" should contain a product named "([^\"]*)"$/ do |arg1, arg2|
  @cat = Category.find_by_name(arg1)
  @prod = Product.where(:name => arg2).first
  @cat.products.should include @prod
end

