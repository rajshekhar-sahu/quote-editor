class Quote < ApplicationRecord
  validates :name, presence: true

  belongs_to :company

  # after_create_commit -> { broadcast_prepend_to 'quotes', partial: 'quotes/quote', locales: { quote: self }, target: 'quotes' }
  # It instructs our Ruby on Rails application that the HTML of the created quote should be broadcasted to users subscribed to the "quotes" stream and prepended to the DOM node with the id of "quotes"(Target).
  # Turbo has the default value for the target, which is plural of the model(quotes), so this is also the same:
  # after_create_commit -> { broadcast_prepend_to 'quotes', partial: 'quotes/quote', locales: { quote: self } }
  # Turbo has default values for partial and locales as well. For partial it is equal to calling `to_partial_path` on instance of model, which by default in Rails for our Quote model is equal to "quotes/quote".
  # The locals default value is equal to { model_name.element.to_sym => self } which, in in the context of our Quote model, is equal to { quote: self }.
  # In the end this is the shortest form:
  # after_create_commit -> { broadcast_prepend_to 'quotes' }

  # For replace and remove target's default value will be dom_id(self).
  # after_update_commit -> { broadcast_replace_to 'quotes' }
  # after_destroy_commit -> { broadcast_remove_to "quotes" }

  # For making the broadcasting asynchronous use these methods:
  # after_create_commit -> { broadcast_prepend_later_to "quotes" }
  # after_update_commit -> { broadcast_replace_later_to "quotes" }
  # after_destroy_commit -> { broadcast_remove_to "quotes" }

  # There is no later_to method for remove, since the quote gets deleted from the database, it would be impossible for a background job to retrieve this quote in the database later to perform the job.

  # Those three callbacks are equivalent to the following single line
  broadcasts_to ->(quote) { [quote.company, "quotes"] }, inserts_by: :prepend

  scope :ordered, ->() { order(id: :desc) }
end

# == Schema Information
#
# Table name: quotes
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer          not null, indexed
#
# Indexes
#
#  index_quotes_on_company_id  (company_id)
#
# Foreign Keys
#
#  company_id  (company_id => companies.id)
#
