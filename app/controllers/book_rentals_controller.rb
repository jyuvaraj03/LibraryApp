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
    book_ids = Array(book_rental_params[:book_id]).reject(&:blank?)
    member_id = book_rental_params[:member_id]
    issued_on = book_rental_params[:issued_on]

    @book_rentals = []
    @errors = []

    current_rentals_count = BookRental.current.where(member_id: member_id).count
    max_rentals = BookRental::MAX_RENTALS
    if current_rentals_count + book_ids.size > max_rentals
      @book_rental = BookRental.new(book_rental_params)
      flash.now[:form_errors] = [I18n.t('exceeds_max_rentals', max: max_rentals)]
      render 'new' and return
    end

    ActiveRecord::Base.transaction do
      book_ids.each do |book_id|
        rental = BookRental.new(book_id: book_id, member_id: member_id, issued_on: issued_on)
        unless rental.save
          @errors += rental.errors.full_messages
          raise ActiveRecord::Rollback
        end
        @book_rentals << rental
      end
    end

    if @errors.empty?
      due_date = @book_rentals.first.due_by&.to_formatted_s(:long)
      flash[:snack_success] = I18n.t('successfully_created_rental_due_by', due_by: due_date)
      redirect_to book_rentals_path
    else
      @book_rental = BookRental.new(book_rental_params)
      flash.now[:form_errors] = @errors.uniq
      render 'new'
    end
  end

  private

  def book_rental_params
    params
      .require(:book_rental)
      .reject { |_k, v| v.blank? }
      .permit(:member_id, :issued_on, book_id: [])
  end

  def book_rental_filter_params
    params
      .transform_values { |x| x.strip.gsub(/\s+/, ' ') if x.respond_to?('strip') }
      .permit(:search, :show_all)
  end
end
