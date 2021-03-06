require 'spec_helper'

describe ActsAsTaggableArrayOn::Taggable do
  before do
    @user1 = User.create name: 'Tom', colors: ['red', 'blue'], shapes: ['triangle']  
    @user2 = User.create name: 'Ken', colors: ['black', 'white', 'red'], shapes: ['circle', 'square']  
    @user3 = User.create name: 'Joe', colors: ['black', 'blue'], shapes: ['circle']    

    User.acts_as_taggable_array_on :colors, :shapes
  end

  describe "#acts_as_taggable_array_on" do
    it "defines named scope to match any tags" do
      expect(User).to respond_to(:with_any_colors)
      expect(User).to respond_to(:with_any_shapes)
    end
    it "defines named scope to match all tags" do
      expect(User).to respond_to(:with_all_colors)
      expect(User).to respond_to(:with_all_shapes)
    end
    it "defines named scope not to match any tags" do
      expect(User).to respond_to(:without_any_colors)
      expect(User).to respond_to(:without_any_shapes)
    end
    it "defines named scope not to match all tags" do
      expect(User).to respond_to(:without_all_colors)
      expect(User).to respond_to(:without_all_shapes)
    end
  end

  describe "#with_any_tags" do
    it "returns users having any tags of args" do
      expect(User.with_any_colors(['red', 'blue'])).to match_array([@user1,@user2,@user3])
      expect(User.with_any_colors('red, blue')).to match_array([@user1,@user2,@user3])
    end
  end

  describe "#with_all_tags" do
    it "returns users having all tags of args" do
      expect(User.with_all_colors(['red', 'blue'])).to match_array([@user1])
      expect(User.with_all_colors('red, blue')).to match_array([@user1])
    end
  end

  describe "#without_any_tags" do
    it "returns users not having any tags of args" do
      expect(User.without_any_colors(['red', 'blue'])).to match_array([])
      expect(User.without_any_colors('red, blue')).to match_array([])
    end
  end

  describe "#without_all_tags" do
    it "returns users not having all tags of args" do
      expect(User.without_all_colors(['red', 'blue'])).to match_array([@user2,@user3])
      expect(User.without_all_colors('red, blue')).to match_array([@user2,@user3])
    end
  end

  describe "#all_colors" do
    it "returns all of tag_name" do
      expect(User.all_colors).to match_array([@user1,@user2,@user3].map(&:colors).flatten.uniq)
    end

    it "returns filtered tags for tag_name with block" do
      expect(User.all_colors{where(name: ["Ken", "Joe"])}).to match_array([@user2,@user3].map(&:colors).flatten.uniq)
    end

    it "returns filtered tags for tag_name with prepended scope" do
      expect(User.where('tag like ?', 'bl%').all_colors).to match_array([@user1,@user2,@user3].map(&:colors).flatten.uniq.select{|name| name.start_with? 'bl'})
    end

    it "returns filtered tags for tag_name with prepended scope and bock" do
      expect(User.where('tag like ?', 'bl%').all_colors{where(name: ["Ken", "Joe"])}).to match_array([@user2,@user3].map(&:colors).flatten.uniq.select{|name| name.start_with? 'bl'})
    end
  end

  describe "#colors_cloud" do
    it "returns tag cloud for tag_name" do
      expect(User.colors_cloud).to match_array(
        [@user1,@user2,@user3].map(&:colors).flatten.group_by(&:to_s).map{|k,v| [k,v.count]}
      )
    end

    it "returns filtered tag cloud for tag_name with block" do
      expect(User.colors_cloud{where(name: ["Ken", "Joe"])}).to match_array(
        [@user2,@user3].map(&:colors).flatten.group_by(&:to_s).map{|k,v| [k,v.count]}
      )
    end

    it "returns filtered tag cloud for tag_name with prepended scope" do
      expect(User.where('tag like ?', 'bl%').colors_cloud).to match_array(
        [@user1,@user2,@user3].map(&:colors).flatten.group_by(&:to_s).map{|k,v| [k,v.count]}.select{|name,count| name.start_with? 'bl'}
      )
    end

    it "returns filtered tag cloud for tag_name with prepended scope and block" do
      expect(User.where('tag like ?', 'bl%').colors_cloud{where(name: ["Ken", "Joe"])}).to match_array(
        [@user2,@user3].map(&:colors).flatten.group_by(&:to_s).map{|k,v| [k,v.count]}.select{|name,count| name.start_with? 'bl'}
      )
    end
  end

  describe "with complex scope" do
    it "works properly" do
      expect(User.without_any_colors('white').with_any_colors('blue').order(:created_at).limit(10)).to eq [@user1, @user3]
    end
  end
end
