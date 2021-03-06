require 'spec_helper'

if Rails.version.to_i == 2
  describe Bullet::Detector::Association, 'has_many' do
    before(:each) do
      Bullet.clear
      Bullet.start_request
    end

    after(:each) do
      Bullet.end_request
    end

    context "post => comments" do
      it "should detect non preload post => comments" do
        Post.all.each do |post|
          post.comments.map(&:name)
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_detecting_unpreloaded_association_for(Post, :comments)
      end

      it "should detect preload with post => comments" do
        Post.all(:include => :comments).each do |post|
          post.comments.map(&:name)
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should detect unused preload post => comments" do
        Post.all(:include => :comments).map(&:name)
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should be_unused_preload_associations_for(Post, :comments)

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should not detect unused preload post => comments" do
        Post.all.map(&:name)
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end
    end

    context "category => posts => comments" do
      it "should detect non preload category => posts => comments" do
        Category.all.each do |category|
          category.posts.each do |post|
            post.comments.map(&:name)
          end
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_detecting_unpreloaded_association_for(Category, :posts)
        Bullet::Detector::Association.should be_detecting_unpreloaded_association_for(Post, :comments)
      end

      it "should detect preload category => posts, but no post => comments" do
        Category.all(:include => :posts).each do |category|
          category.posts.each do |post|
            post.comments.collect(&:name)
          end
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should_not be_detecting_unpreloaded_association_for(Category, :posts)
        Bullet::Detector::Association.should be_detecting_unpreloaded_association_for(Post, :comments)
      end

      it "should detect preload with category => posts => comments" do
        Category.all(:include => {:posts => :comments}).each do |category|
          category.posts.each do |post|
            post.comments.map(&:name)
          end
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should detect unused preload with category => posts => comments" do
        Category.all(:include => {:posts => :comments}).map(&:name)
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should be_unused_preload_associations_for(Post, :comments)

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should detect unused preload with post => commnets, no category => posts" do
        Category.all(:include => {:posts => :comments}).each do |category|
          category.posts.map(&:name)
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should be_unused_preload_associations_for(Post, :comments)

        Bullet::Detector::Association.should be_completely_preloading_associations
      end
    end

    context "category => posts, category => entries" do
      it "should detect non preload with category => [posts, entries]" do
        Category.all.each do |category|
          category.posts.map(&:name)
          category.entries.map(&:name)
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_detecting_unpreloaded_association_for(Category, :posts)
        Bullet::Detector::Association.should be_detecting_unpreloaded_association_for(Category, :entries)
      end

      it "should detect preload with category => posts, but not with category => entries" do
        Category.all(:include => :posts).each do |category|
          category.posts.map(&:name)
          category.entries.map(&:name)
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should_not be_detecting_unpreloaded_association_for(Category, :posts)
        Bullet::Detector::Association.should be_detecting_unpreloaded_association_for(Category, :entries)
      end

      it "should detect preload with category => [posts, entries]" do
        Category.all(:include => [:posts, :entries]).each do |category|
          category.posts.map(&:name)
          category.entries.map(&:name)
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should detect unused preload with category => [posts, entries]" do
        Category.all(:include => [:posts, :entries]).map(&:name)
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should be_unused_preload_associations_for(Category, :posts)
        Bullet::Detector::Association.should be_unused_preload_associations_for(Category, :entries)

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should detect unused preload with category => entries, but not with category => posts" do
        Category.all(:include => [:posts, :entries]).each do |category|
          category.posts.map(&:name)
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_unused_preload_associations_for(Category, :posts)
        Bullet::Detector::Association.should be_unused_preload_associations_for(Category, :entries)

        Bullet::Detector::Association.should be_completely_preloading_associations
      end
    end

    context "post => comment" do
      it "should detect unused preload with post => comments" do
        Post.all(:include => :comments).each do |post|
          post.comments.first.name
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_unused_preload_associations_for(Post, :comments)

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should detect preload with post => commnets" do
        Post.first.comments.collect(&:name)
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end
    end

    context "category => posts => writer" do
      it "should not detect unused preload associations" do
        category = Category.first(:include => {:posts => :writer}, :order => "id DESC", :conditions => {:name => 'first'})
        category.posts.map do |post|
          post.name
          post.writer.name
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_unused_preload_associations_for(Category, :posts)
        Bullet::Detector::Association.should_not be_unused_preload_associations_for(Post, :writer)
      end
    end

    context "scope for_category_name" do
      it "should detect preload with post => category" do
        Post.in_category_name('first').all.each do |post|
          post.category.name
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should not be unused preload post => category" do
        Post.in_category_name('first').all.map(&:name)
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end
    end

    context "scope preload_comments" do
      it "should detect preload post => comments with scope" do
        Post.preload_comments.each do |post|
          post.comments.map(&:name)
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should detect unused preload with scope" do
        Post.preload_comments.map(&:name)
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should be_unused_preload_associations_for(Post, :comments)

        Bullet::Detector::Association.should be_completely_preloading_associations
      end
    end
  end

  describe Bullet::Detector::Association, 'belongs_to' do
    before(:each) do
      Bullet.clear
      Bullet.start_request
    end

    after(:each) do
      Bullet.end_request
    end

    context "comment => post" do
      it "should detect non preload with comment => post" do
        Comment.all.each do |comment|
          comment.post.name
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_detecting_unpreloaded_association_for(Comment, :post)
      end

      it "should detect preload with one comment => post" do
        Comment.first.post.name
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should dtect preload with comment => post" do
        Comment.all(:include => :post).each do |comment|
          comment.post.name
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should not detect preload with comment => post" do
        Comment.all.collect(&:name)
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should detect unused preload with comments => post" do
        Comment.all(:include => :post).map(&:name)
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should be_unused_preload_associations_for(Comment, :post)

        Bullet::Detector::Association.should be_completely_preloading_associations
      end
    end

    context "comment => post => category" do
      it "should detect non preload association with comment => post" do
        Comment.all.each do |comment|
          comment.post.category.name
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_detecting_unpreloaded_association_for(Comment, :post)
      end

      it "should detect non preload association with post => category" do
        Comment.all(:include => :post).each do |comment|
          comment.post.category.name
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_detecting_unpreloaded_association_for(Post, :category)
      end

      it "should not detect unpreload association" do
        Comment.all(:include => {:post => :category}).each do |comment|
          comment.post.category.name
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end
    end

    context "comment => author, post => writer" do
      # this happens because the post isn't a possible object even though the writer is access through the post
      # which leads to an 1+N queries
      it "should detect non preloaded writer" do
        Comment.all(:include => [:author, :post], :conditions => ["base_users.id = ?", BaseUser.first]).each do |comment|
          comment.post.writer.name
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_detecting_unpreloaded_association_for(Post, :writer)
      end

      # this happens because the comment doesn't break down the hash into keys
      # properly creating an association from comment to post
      it "should detect unused preload with comment => author" do
        Comment.all(:include => [:author, {:post => :writer}], :conditions => ["base_users.id = ?", BaseUser.first]).each do |comment|
          comment.post.writer.name
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should be_unused_preload_associations_for(Comment, :author)

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      # To flyerhzm: This does not detect that newspaper is unpreloaded. The association is
      # not within possible objects, and thus cannot be detected as unpreloaded
      it "should detect non preloading with writer => newspaper" do
        Comment.all(:include => {:post => :writer}, :conditions => "posts.name like '%first%'").each do |comment|
          comment.post.writer.newspaper.name
        end
        #Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        #Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_detecting_unpreloaded_association_for(Writer, :newspaper)
      end

      # when we attempt to access category, there is an infinite overflow because load_target is hijacked leading to
      # a repeating loop of calls in this test
      it "should not raise a stack error from posts to category" do
        lambda {
          Comment.all(:include => {:post => :category}).each do |com|
            com.post.category
          end
        }.should_not raise_error(SystemStackError)
      end
    end
  end

  describe Bullet::Detector::Association, 'has_and_belongs_to_many' do
    before(:each) do
      Bullet.clear
      Bullet.start_request
    end

    after(:each) do
      Bullet.end_request
    end

    context "students <=> teachers" do
      it "should detect non preload associations" do
        Student.all.each do |student|
          student.teachers.map(&:name)
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_detecting_unpreloaded_association_for(Student, :teachers)
      end

      it "should detect preload associations" do
        Student.all(:include => :teachers).each do |student|
          student.teachers.map(&:name)
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should detect unused preload associations" do
        Student.all(:include => :teachers).map(&:name)
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should be_unused_preload_associations_for(Student, :teachers)

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should detect no unused preload associations" do
        Student.all.collect(&:name)
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end
    end
  end

  describe Bullet::Detector::Association, 'has_many :through' do
    before(:each) do
      Bullet.clear
      Bullet.start_request
    end

    after(:each) do
      Bullet.end_request
    end

    context "firm => clients" do
      it "should detect non preload associations" do
        Firm.all.each do |firm|
          firm.clients.map(&:name)
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_detecting_unpreloaded_association_for(Firm, :clients)
      end

      it "should detect preload associations" do
        Firm.all(:include => :clients).each do |firm|
          firm.clients.map(&:name)
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should not detect preload associations" do
        Firm.all.collect(&:name)
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should detect unused preload associations" do
        Firm.all(:include => :clients).collect(&:name)
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should be_unused_preload_associations_for(Firm, :clients)

        Bullet::Detector::Association.should be_completely_preloading_associations
      end
    end
  end

  describe Bullet::Detector::Association, "has_one" do
    before(:each) do
      Bullet.clear
      Bullet.start_request
    end

    after(:each) do
      Bullet.end_request
    end

    context "company => address" do
      it "should detect non preload association" do
        Company.all.each do |company|
          company.address.name
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_detecting_unpreloaded_association_for(Company, :address)
      end

      it "should detect preload association" do
        Company.find(:all, :include => :address).each do |company|
          company.address.name
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should not detect preload association" do
        Company.all.collect(&:name)
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should detect unused preload association" do
        Company.find(:all, :include => :address).collect(&:name)
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should be_unused_preload_associations_for(Company, :address)

        Bullet::Detector::Association.should be_completely_preloading_associations
      end
    end
  end

  describe Bullet::Detector::Association, "call one association that in possible objects" do
    before(:each) do
      Bullet.clear
      Bullet.start_request
    end

    after(:each) do
      Bullet.end_request
    end

    it "should not detect preload association" do
      Post.all
      Post.first.comments.map(&:name)
      Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
      Bullet::Detector::Association.should_not be_has_unused_preload_associations

      Bullet::Detector::Association.should be_completely_preloading_associations
    end
  end

  describe Bullet::Detector::Association, "STI" do
    before(:each) do
      Bullet.clear
      Bullet.start_request
    end

    after(:each) do
      Bullet.end_request
    end

    context "page => author" do
      it "should detect non preload associations" do
        Page.all.each do |page|
          page.author.name
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_detecting_unpreloaded_association_for(Page, :author)
      end

      it "should detect preload associations" do
        Page.find(:all, :include => :author).each do |page|
          page.author.name
        end
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should detect unused preload associations" do
        Page.find(:all, :include => :author).collect(&:name)
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should be_unused_preload_associations_for(Page, :author)

        Bullet::Detector::Association.should be_completely_preloading_associations
      end

      it "should not detect preload associations" do
        Page.all.collect(&:name)
        Bullet::Detector::UnusedEagerAssociation.check_unused_preload_associations
        Bullet::Detector::Association.should_not be_has_unused_preload_associations

        Bullet::Detector::Association.should be_completely_preloading_associations
      end
    end
  end
end
