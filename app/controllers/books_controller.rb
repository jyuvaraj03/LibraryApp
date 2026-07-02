class BooksController < ApplicationController
  def index
    @pagy, @books = pagy(
      Book
        .includes(:author, :publisher, :categories)
        .filter_by(book_search_params.slice(:availability))
        .search(book_search_params[:search])
        .order(id: :asc),
      items: book_search_params[:max_results] || Pagy::DEFAULT[:items]
    )
    respond_to do |format|
      format.html
      format.json { render json: @books, include: { author: { only: :name } } }
    end
  end

  def new
    @book = Book.new
    authorize @book
  end

  def edit
    @book = Book.find(params[:id])
    authorize @book
    set_book_form_fields
  end

  def create
    authorize Book
    @book = Book.create_with_associated_models(create_book_params)
    if @book.valid?
      flash[:snack_success] = I18n.t('successfully_created_book_name', name: @book.name)
      redirect_to books_path
    else
      redirect_to new_book_path
      flash[:form_errors] = @book.errors.full_messages
    end
  end

  def update
    @book = Book.find(params[:id])
    authorize @book
    @book.update_with_associated_models(update_book_params)
    if @book.valid?
      flash[:snack_success] = I18n.t('successfully_updated_book_name', name: @book.name)
      redirect_to books_path
    else
      set_book_form_fields
      flash.now[:form_errors] = @book.errors.full_messages
      render :edit
    end
  end

  private

  def create_book_params
    bp = params
      .require(:book)
      .transform_values { |x| x.strip.gsub(/\s+/, ' ') if x.respond_to?('strip') }
      .reject { |_, v| v.blank? }
      .permit(:custom_number, :name, :author_name, :publisher_name, :publishing_year, :category_names, :price, :auto_assign_custom_number)

    # If auto_assign_custom_number is present and true, remove custom_number so model can auto-assign
    auto_assign = bp.delete(:auto_assign_custom_number)
    if auto_assign.present? && ActiveModel::Type::Boolean.new.cast(auto_assign)
      bp[:custom_number] = nil
    end
    bp
  end

  def update_book_params
    params
      .require(:book)
      .transform_values { |x| x.strip.gsub(/\s+/, ' ') if x.respond_to?('strip') }
      .permit(:name, :author_name, :publisher_name, :publishing_year, :category_names, :price)
  end

  def set_book_form_fields
    @book.author_name = @book.author&.name
    @book.publisher_name = @book.publisher&.name
    @book.category_names = @book.categories.map(&:name).join(', ')
  end

  def book_search_params
    params
      .transform_values { |x| x.strip.gsub(/\s+/, ' ') if x.respond_to?('strip') }
      .permit(:search, :max_results, :availability)
  end
end
