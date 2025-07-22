require 'test_helper'

class BooksCreateTest < ActionDispatch::IntegrationTest
  def setup
    super
    @author = Author.create(name: 'Trevor Noah')
    @publisher = Publisher.create(name: 'Fox Productions')
    @category1 = Category.create(name: 'Informational News')
    @category2 = Category.create(name: 'Comedy')
    @book = Book.create(name: 'Born A Crime', author: @author, publisher: @publisher, publishing_year: 2009,
                        categories: [@category1, @category2])
    log_in_as(staffs(:admino))
  end

  test 'can create with all the parameters' do
    get new_book_path
    assert_response :success

    assert_difference 'Book.count', 1 do
      post books_path,
           params: {
             book: {
               name: 'Da Vinci Code',
               author_name: 'Dan Brown',
               publisher_name: 'Penguin Labs',
               publishing_year: '2010',
               category_names: 'Mystery, Crime'
             }
           }
      assert_response :redirect
      follow_redirect!
      assert_response :success
    end
  end

  test 'new author is not created when given an existing author_name' do
    get new_book_path
    assert_response :success

    assert_difference 'Book.count', 1 do
      assert_no_difference 'Author.count' do
        post books_path,
             params: {
               book: {
                 name: 'Da Vinci Code',
                 author_name: @author.name,
                 publisher_name: 'Penguin Labs',
                 publishing_year: '2010',
                 category_names: 'Mystery, Crime'
               }
             }
        assert_response :redirect
        follow_redirect!
        assert_response :success
      end
    end
  end

  test 'new publisher is not created when given an existing publisher_name' do
    get new_book_path
    assert_response :success

    assert_difference 'Book.count', 1 do
      assert_no_difference 'Publisher.count' do
        post books_path,
             params: {
               book: {
                 name: 'Da Vinci Code',
                 author_name: 'Dan Brown',
                 publisher_name: @publisher.name,
                 publishing_year: '2010',
                 category_names: 'Mystery, Crime'
               }
             }
        assert_response :redirect
        follow_redirect!
        assert_response :success
      end
    end
  end

  test 'new category is not created when given an existing category in category_names' do
    get new_book_path
    assert_response :success

    assert_difference 'Book.count', 1 do
      assert_no_difference 'Category.count' do
        post books_path,
             params: {
               book: {
                 name: 'Da Vinci Code',
                 author_name: 'Dan Brown',
                 publisher_name: 'Penguin Labs',
                 publishing_year: '2010',
                 category_names: @category1.name
               }
             }
        assert_response :redirect
        follow_redirect!
        assert_response :success
      end
    end
  end

  test 'can be created with empty category_names' do
    get new_book_path
    assert_response :success

    assert_difference 'Book.count', 1 do
      post books_path,
           params: {
             book: {
               name: 'Da Vinci Code',
               author_name: 'Dan Brown',
               publisher_name: 'Penguin Labs',
               publishing_year: '2010',
               category_names: ''
             }
           }
      assert_response :redirect
      follow_redirect!
      assert_response :success
    end
  end

  test 'can be created with empty publishing_year' do
    get new_book_path
    assert_response :success

    assert_difference 'Book.count', 1 do
      post books_path,
           params: {
             book: {
               name: 'Da Vinci Code',
               author_name: 'Dan Brown',
               publisher_name: 'Penguin Labs',
               publishing_year: '',
               category_names: 'Mystery, Thriller'
             }
           }
      assert_response :redirect
      follow_redirect!
      assert_response :success
    end
  end

  test 'can be created with empty publisher_name' do
    get new_book_path
    assert_response :success

    assert_difference 'Book.count', 1 do
      post books_path,
           params: {
             book: {
               name: 'Da Vinci Code',
               author_name: 'Dan Brown',
               publisher_name: '',
               publishing_year: '2010',
               category_names: 'Mystery, Thriller'
             }
           }
      assert_response :redirect
      follow_redirect!
      assert_response :success
    end
  end

  test 'can be created with empty author_name' do
    get new_book_path
    assert_response :success

    assert_difference 'Book.count', 1 do
      post books_path,
           params: {
             book: {
               name: 'Da Vinci Code',
               author_name: '',
               publisher_name: 'Penguin Labs',
               publishing_year: '2010',
               category_names: 'Mystery, Thriller'
             }
           }
      assert_response :redirect
      follow_redirect!
      assert_response :success
    end
  end

  test 'cannot be created with empty name' do
    get new_book_path
    assert_response :success

    assert_no_difference 'Book.count' do
      post books_path,
           params: {
             book: {
               name: '',
               author_name: 'Dan Brown',
               publisher_name: 'Penguin Labs',
               publishing_year: '2010',
               category_names: 'Mystery, Thriller'
             }
           }
      assert_redirected_to new_book_path
      assert_not_nil flash[:form_errors]
    end
  end

  test 'failing book create should not create associated model instances' do
    assert_no_difference ['Book.count', 'Author.count', 'Publisher.count', 'Category.count'] do
      post books_path,
           params: {
             book: {
               name: '',  # Empty name will make book create fail
               author_name: 'Dan Brown',
               publisher_name: 'Penguin Labs',
               publishing_year: '2010',
               category_names: 'Mystery, Thriller'
             }
           }
      assert_redirected_to new_book_path
      assert_not_nil flash[:form_errors]
    end
  end

  test 'can be created with one category' do
    get new_book_path
    assert_response :success

    assert_difference ['Category.count'], 1 do
      post books_path,
           params: {
             book: {
               name: 'Da Vinci Code',
               author_name: 'Dan Brown',
               publisher_name: 'Penguin Labs',
               publishing_year: '2010',
               category_names: 'Mystery'
             }
           }
      assert_response :redirect
      follow_redirect!
      assert_response :success
    end
  end

  test 'parameters should be stripped and squished' do
    assert_difference ['Book.count', 'Author.count', 'Publisher.count', 'Category.count'], 1 do
      post books_path,
           params: {
             book: {
               name: ' Da  Vinci     Code    ',
               author_name: '  Dan Brown   ',
               publisher_name: '    Penguin Labs    ',
               publishing_year: '2010',
               category_names: '    Mystery        '
             }
           }
      assert_response :redirect
      follow_redirect!
      assert_response :success
    end
  end

  test 'should not create new author if author name contains extra whitespace' do
    get new_book_path
    assert_response :success

    assert_difference ['Book.count', 'Publisher.count', 'Category.count'], 1 do
      assert_no_difference 'Author.count' do
        post books_path,
             params: {
               book: {
                 name: 'Da Vinci Code',
                 author_name: "   #{@author.name.gsub(/\s/, '    ')}   ",
                 publisher_name: 'Penguin Labs',
                 publishing_year: '2010',
                 category_names: 'Mystery'
               }
             }
        assert_response :redirect
        follow_redirect!
        assert_response :success
      end
    end
  end

  test 'should not create new publisher if publisher name contains extra whitespace' do
    get new_book_path
    assert_response :success

    assert_difference ['Book.count', 'Author.count', 'Category.count'], 1 do
      assert_no_difference 'Publisher.count' do
        post books_path,
             params: {
               book: {
                 name: 'Da Vinci Code',
                 author_name: 'Dan Brown',
                 publisher_name: "   #{@publisher.name.gsub(/\s/, '    ')}   ",
                 publishing_year: '2010',
                 category_names: 'Mystery'
               }
             }
        assert_response :redirect
        follow_redirect!
        assert_response :success
      end
    end
  end

  test 'should not create new category if category contains extra whitespace' do
    get new_book_path
    assert_response :success

    assert_difference ['Book.count', 'Author.count', 'Publisher.count'], 1 do
      assert_no_difference 'Category.count' do
        post books_path,
             params: {
               book: {
                 name: 'Da Vinci Code',
                 author_name: 'Dan Brown',
                 publisher_name: 'Penguin Labs',
                 publishing_year: '2010',
                 category_names: "   #{@category1.name.gsub(/\s/, '    ')}   "
               }
             }
        assert_response :redirect
        follow_redirect!
        assert_response :success
      end
    end
  end

  test 'cannot create book when logged out' do
    delete logout_path
    post books_path,
         params: {
           book: {
             name: 'Da Vinci Code',
             author_name: 'Dan Brown',
             publisher_name: 'Penguin Labs',
             publishing_year: '2010',
             category_names: 'Mystery, Crime'
           }
         }
    assert_response :redirect
    follow_redirect!
    assert_response :success
    # Check for the actual warning message shown to unauthenticated users
    assert_match 'நூலக செயல்பாடுகளை அணுக நிர்வாகியாக', response.body
  end
end
