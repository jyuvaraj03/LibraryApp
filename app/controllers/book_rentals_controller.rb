class BookRentalsController < ApplicationController
  def index
    authorize BookRental
    @pagy, @book_rentals = pagy(BookRental
                                  .includes(:book, :member)
                                  .filter_by_show_all(book_rental_filter_params[:show_all])
                                  .search(book_rental_filter_params[:search])
                                  .order(issued_on: :desc))
  end

  def new
    authorize BookRental
    @book_rental = BookRental.new
  end

  def create
    authorize BookRental
    @book_rental = BookRental.create(book_rental_params)
    if @book_rental.valid?
      flash[:snack_success] = I18n.t('successfully_created_rental_due_by', due_by: @book_rental.due_by&.to_formatted_s(:long))
      redirect_to book_rentals_path
    else
      flash.now[:form_errors] = @book_rental.errors.full_messages
      render 'new'
    end
  end

  private

  def book_rental_params
    params
      .require(:book_rental)
      .transform_values { |x| x.strip.gsub(/\s+/, ' ') if x.respond_to?('strip') }
      .reject { |_k, v| v.blank? }
      .permit(:book_id, :member_id, :issued_on)
  end

  def book_rental_filter_params
    params
      .transform_values { |x| x.strip.gsub(/\s+/, ' ') if x.respond_to?('strip') }
      .permit(:search, :show_all)
  end
end
