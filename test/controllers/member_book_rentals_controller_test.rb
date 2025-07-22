require "test_helper"

class MemberBookRentalsControllerTest < ActionDispatch::IntegrationTest
  test "should contain the member's current book rentals" do
    member = members(:phineas)
    book = books(:unborrowed)
    new_book_rental = member.book_rentals.create(book: book, issued_on: Date.today)
    assert new_book_rental.valid?

    get member_book_rentals_path, params: { member_id: member.id, format: :json }

    json_response = JSON.parse(response.body)
    response_book_rental_ids = json_response.map { |x| x['id'] }

    assert_includes response_book_rental_ids, new_book_rental.id
  end

  test "should not contain the member's returned book rentals" do
    member = members(:phineas)
    book = books(:unborrowed)
    new_book_rental = member.book_rentals.create(book: book, issued_on: 2.days.ago, returned_on: Date.today)
    assert new_book_rental.valid?

    get member_book_rentals_path, params: { member_id: member.id, format: :json }

    json_response = JSON.parse(response.body)
    response_book_rental_ids = json_response.map { |x| x['id'] }

    assert_not_includes response_book_rental_ids, new_book_rental.id
  end
end
