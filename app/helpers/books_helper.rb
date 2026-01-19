module BooksHelper
  def display_price(book)
    return unless book.price.present?

    # rupee symbol appended
    return "&#8377; #{number_with_precision(book.price, precision: 2)}".html_safe
  end
end
