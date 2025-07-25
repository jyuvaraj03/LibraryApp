class ReturnsController < ApplicationController
  before_action :authorize_book_rental
  before_action :get_book_rental, only: [:new]

  def new
    @book_rental = BookRental.new
  end

  def create
    @book_rentals = BookRental.current.where(member_id: return_params[:member_id], id: return_params[:book_rental_ids])
    if @book_rentals.count.zero?
      flash[:form_error] = I18n.t('book_rentals_not_found_for_given_member')
    else
      @book_rentals.update(returned_on: return_params[:returned_on])
      flash[:snack_success] = I18n.t('successfully_returned_books_for_member', member_custom_number: @book_rentals.first.member.custom_number)
    end

    redirect_to book_rentals_path
  end

  def return_params
    params
      .require(:return)
      .permit(:member_id, :returned_on, book_rental_ids: [])
  end

  private

  def authorize_book_rental
    authorize BookRental
  end

  def get_book_rental
    @book_rental = BookRental.find_by(id: params[:book_rental_id]) || BookRental.new
  end
end
