require File.expand_path("#{File.dirname(__FILE__)}/spec_helper")

RSpec.describe FindOrCreateOnScopes do
  {
      find_or_create:     :save,
      find_or_create!:    :save!,
      find_or_initialize: nil
  }.each do |meth, saver|
    describe "##{meth}" do
      it "should find an object if a matching one exists" do
        record = Option.create!(name: 'foo', value: 'bar')
        expect(Option.where(name: 'foo').send(meth, value: 'bar2')).to eql(record)
      end

      it "should create an object if a matching one does not exist" do
        Option.create!(name: 'foo2', value: 'bar2')
        record = Option.where(name: 'foo').send(meth, value: 'bar2')
        expect(record.name).to eql('foo')
        expect(record.value).to eql('bar2')
      end

      it "should do so in a transaction" do
        expect(Option).to receive(:transaction)
        Option.where(name: 'foo').send(meth, value: 'bar')
      end

      it "should yield the object to the block" do
        record = Option.where(name: 'foo').send(meth, value: 'bar') { |u| u.field = "foobar" }
        expect(record.field).to eql('foobar')
      end

      it "should not yield a persisted object to the block" do
        record = Option.create!(name: 'foo', field: 'foobar')
        expect { Option.where(name: 'foo').send(meth, value: 'bar') { |u| u.field = "foobar2" } }.not_to change(Option, :count)
        expect(record.field).to eql('foobar')
      end

      if saver
        it "should call #{saver}" do
          record = Option.new
          allow(Option).to receive(:new).and_return(record)
          expect(record).to receive(saver).once.and_return(true)
          expect(Option.where(name: 'foo').send(meth, value: 'bar')).to eql(record)
        end

        it "should not call #{saver} on an existing record" do
          record = Option.create!(name: 'foo', value: 'bar')
          expect(record).not_to receive(saver)
          expect(Option.where(name: 'foo').send(meth, value: 'bar')).to eql(record)
        end

        it "should ignore a duplicate key error and return the existing record" do
          record = Option.create!(name: 'foo', value: 'bar')
          allow_any_instance_of(Option).to receive(saver) do
            if @once then record
            else
              @once = true
              raise ActiveRecord::RecordNotUnique, "Duplicate entry 'foo@bar.com' for key 'index_email_addresses_on_email'"
            end
          end
          expect(Option.where(name: 'foo').send(meth, value: 'bar').id).to eql(record.id)
          expect(Option.count).to be(1)
        end

        it "should not save the record if ABORT_SAVE is returned from the block" do
          record = Option.new
          allow(Option).to receive(:new).and_return(record)
          expect(record).not_to receive(saver)
          expect(Option.where(name: 'foo').send(meth, value: 'bar') { FindOrCreateOnScopes::ABORT_SAVE }).to eql(record)
        end
      end
    end
  end

  {
      create_or_update:     :save,
      create_or_update!:    :save!,
      initialize_or_update: nil
  }.each do |meth, saver|
    describe "##{meth}" do
      it "should find an object and update it if a matching one exists" do
        record = Option.create!(name: 'foo', value: 'bar')
        if saver
          expect(Option.where(name: 'foo').send(meth, value: 'bar2')).to eql(record)
          record.reload
        else
          record = Option.where(name: 'foo').send(meth, value: 'bar2')
        end
        expect(record.value).to eql('bar2')
      end

      it "should create an object if a matching one does not exist" do
        Option.create!(name: 'foo2', value: 'bar2')
        record = Option.where(name: 'foo').send(meth, value: 'bar')
        expect(record.name).to eql('foo')
        expect(record.value).to eql('bar')
      end

      it "should do so in a transaction" do
        expect(Option).to receive(:transaction)
        Option.where(name: 'foo').send(meth, value: 'bar')
      end

      it "should yield the object to the block" do
        record = Option.where(name: 'foo').send(meth, value: 'bar') { |u| u.field = "foobar" }
        expect(record.field).to eql('foobar')

        record = Option.where(name: 'foo').send(meth, value: 'bar') { |u| u.field = "foobar2" }
        expect(record.field).to eql('foobar2')
      end

      it "should not call #assign_attributes if no arguments are given" do
        record = Option.where(name: 'foo').send(meth) { |u| u.field = 'foobar' }
        expect(record.field).to eql('foobar')

        record = Option.where(name: 'foo').send(meth) { |u| u.field = "foobar2" }
        expect(record.field).to eql('foobar2')
      end

      if saver
        it "should call #{saver}" do
          record = Option.new
          allow(Option).to receive(:new).and_return(record)
          expect(record).to receive(saver).and_return(true)
          expect(Option.where(name: 'foo').send(meth, value: 'bar')).to eql(record)
        end

        it "should ignore a duplicate key error and update the existing record" do
          record = Option.create!(name: 'foo', value: 'bar')
          allow_any_instance_of(Option).to receive(saver) do
            if @once
              record.value = 'bar2'
              record.send :_update_record
            else
              @once = true
              raise ActiveRecord::RecordNotUnique, "Duplicate entry 'foo@bar.com' for key 'index_email_addresses_on_email'"
            end
          end
          expect(Option.where(name: 'foo').send(meth, value: 'bar2').id).to eql(record.id)
          expect(record.reload.value).to eql('bar2')
        end

        it "should not ignore a duplicate key error if it's not a key from the scope" do
          Option.create! name: 'foo', value: 'bar', uniq: '123'
          expect { Option.where(name: 'foo2').send(meth, value: 'bar2', uniq: '123') }.to raise_error(ActiveRecord::RecordNotUnique)
        end

        it "should not save the record if ABORT_SAVE is returned from the block" do
          record = Option.new
          allow(Option).to receive(:new).and_return(record)
          expect(record).not_to receive(saver)
          expect(Option.where(name: 'foo').send(meth, value: 'bar') { FindOrCreateOnScopes::ABORT_SAVE }).to eql(record)
        end
      end
    end
  end
end
