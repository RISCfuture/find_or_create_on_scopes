require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FindOrCreateOnScopes do
  {
    :find_or_create => :save,
    :find_or_create! => :save!,
    :find_or_initialize => nil
  }.each do |meth, saver|
    describe "##{meth}" do
      it "should find an object if a matching one exists" do
        record = Option.create!(name: 'foo', value: 'bar')
        Option.where(name: 'foo').send(meth, value: 'bar2').should eql(record)
      end

      it "should create an object if a matching one does not exist" do
        Option.create!(name: 'foo2', value: 'bar2')
        record = Option.where(name: 'foo').send(meth, value: 'bar2')
        record.name.should eql('foo')
        record.value.should eql('bar2')
      end

      it "should do so in a transaction" do
        Option.should_receive(:transaction)
        Option.where(name: 'foo').send(meth, value: 'bar')
      end

      it "should yield the object to the block" do
        record = Option.where(name: 'foo').send(meth, value: 'bar') { |u| u.field = "foobar" }
        record.field.should eql('foobar')
      end

      it "should not yield a persisted object to the block" do
        record = Option.create!(name: 'foo', field: 'foobar')
        lambda { Option.where(name: 'foo').send(meth, value: 'bar') { |u| u.field = "foobar2" } }.should_not change(Option, :count)
        record.field.should eql('foobar')
      end

      if saver then
        it "should call #{saver}" do
          record = Option.new
          Option.stub(:new).and_return(record)
          record.should_receive(saver).once.and_return(true)
          Option.where(name: 'foo').send(meth, value: 'bar').should eql(record)
        end

        it "should not call #{saver} on an existing record" do
          record = Option.create!(name: 'foo', value: 'bar')
          record.should_not_receive(saver)
          Option.where(name: 'foo').send(meth, value: 'bar').should eql(record)
        end

        it "should ignore a duplicate key error and return the existing record" do
          record = Option.create!(name: 'foo', value: 'bar')
          Option.any_instance.stub(saver) do
            if @once then record
            else
              @once = true
              raise ActiveRecord::RecordNotUnique.new("Duplicate entry 'foo@bar.com' for key 'index_email_addresses_on_email'", nil)
            end
          end
          Option.where(name: 'foo').send(meth, value: 'bar').id.should eql(record.id)
          Option.count.should eql(1)
        end
      end
    end
  end

  {
    :create_or_update => :save,
    :create_or_update! => :save!,
    :initialize_or_update => nil
  }.each do |meth, saver|
    describe "##{meth}" do
      it "should find an object and update it if a matching one exists" do
        record = Option.create!(name: 'foo', value: 'bar')
        if saver then
          Option.where(name: 'foo').send(meth, value: 'bar2').should eql(record)
          record.reload
        else
          record = Option.where(name: 'foo').send(meth, value: 'bar2')
        end
        record.value.should eql('bar2')
      end

      it "should create an object if a matching one does not exist" do
        Option.create!(name: 'foo2', value: 'bar2')
        record = Option.where(name: 'foo').send(meth, value: 'bar')
        record.name.should eql('foo')
        record.value.should eql('bar')
      end

      it "should do so in a transaction" do
        Option.should_receive(:transaction)
        Option.where(name: 'foo').send(meth, value: 'bar')
      end

      it "should yield the object to the block" do
        record = Option.where(name: 'foo').send(meth, value: 'bar') { |u| u.field = "foobar" }
        record.field.should eql('foobar')

        record = Option.where(name: 'foo').send(meth, value: 'bar') { |u| u.field = "foobar2" }
        record.field.should eql('foobar2')
      end

      it "should not call #assign_attributes if no arguments are given" do
        record = Option.where(name: 'foo').send(meth) { |u| u.field = 'foobar' }
        record.field.should eql('foobar')

        record = Option.where(name: 'foo').send(meth) { |u| u.field = "foobar2" }
        record.field.should eql('foobar2')
      end

      if saver then
        it "should call #{saver}" do
          record = Option.new
          Option.stub(:new).and_return(record)
          record.should_receive(saver).and_return(true)
          Option.where(name: 'foo').send(meth, value: 'bar').should eql(record)
        end

        it "should ignore a duplicate key error and update the existing record" do
          record = Option.create!(name: 'foo', value: 'bar')
          Option.any_instance.stub(saver) do
            if @once then
              record.value = 'bar2'
              record.send :update_record
            else
              @once = true
              raise ActiveRecord::RecordNotUnique.new("Duplicate entry 'foo@bar.com' for key 'index_email_addresses_on_email'", nil)
            end
          end
          Option.where(name: 'foo').send(meth, value: 'bar2').id.should eql(record.id)
          record.reload.value.should eql('bar2')
        end
      end
    end
  end
end
