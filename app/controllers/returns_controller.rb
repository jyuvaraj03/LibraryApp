class ReturnsController < ApplicationController
  def new
    @book_rental = BookRental.new
  end

  def create
    @book_rentals = BookRental.current.where(member_id: return_params[:member_id], id: return_params[:book_rental_ids])
    @book_rentals.update(returned_on: return_params[:returned_on])

    redirect_to new_return_path
  end

  def return_params
    params
      .require(:return)
      .permit(:member_id, :returned_on, book_rental_ids: [])
  end
end