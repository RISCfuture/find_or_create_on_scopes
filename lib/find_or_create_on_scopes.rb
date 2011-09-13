# Adds @find_or_create@-type methods to named scopes.

module FindOrCreateOnScopes

  # Locates a record according to the current scope. Returns the record if
  # found. If not found, creates a new record with the options of the current
  # scope and @create_options@.
  #
  # @param [Hash] create_options Attributes to apply to the record if it's newly
  #   created.
  # @yield [record] Yields the record before it is saved.
  # @yieldparam [ActiveRecord::Base] record The found or created record before
  #   it is saved.
  # @return [ActiveRecord::Base] The found or created record.

  def find_or_create(create_options={}, &block)
    find_or_initialize_and_do :save, create_options, &block
  end

  # Same as {#find_or_create} but calls @save!@ instead of @save@ on the record.
  #
  # @see #find_or_create

  def find_or_create!(create_options={}, &block)
    find_or_initialize_and_do :save!, create_options, &block
  end

  # Same as {#find_or_create} but does not save the record. Please note that
  # unless this method is called in a transaction, you might have a race
  # condition when trying to save the record.
  #
  # @see #find_or_create

  def find_or_initialize(init_options={}, &block)
    find_or_initialize_and_do nil, init_options, &block
  end

  # Locates a record according to the current scope. Updates the record with
  # @update_options@ if found. If not found, creates a new record with the
  # current scope's options and @update_options@.
  #
  # @param [Hash] update_options Attributes to apply to the record whether or
  #   not it's newly created.
  # @yield [record] Yields the record before it is saved.
  # @yieldparam [ActiveRecord::Base] record The found or created record before
  #   it is saved.
  # @return [ActiveRecord::Base] The found or created record.

  def create_or_update(update_options={}, &block)
    create_or_update_and_do :save, update_options, &block
  end

  # Same as {#create_or_update} but calls @save!@ instead of @save@ on the
  # record.
  #
  # @see #create_or_update

  def create_or_update!(update_options={}, &block)
    create_or_update_and_do :save!, update_options, &block
  end
  
  # Same as {#create_or_update} but does not save the record. Please note that
  # unless this method is called in a transaction, you might have a race
  # condition when trying to save the record.
  #
  # @see #create_or_update
  
  def initialize_or_update(*args, &block)
    create_or_update_and_do nil, *args, &block
  end

  private

  def find_or_initialize_and_do(meth, options)
    record = nil
    transaction do
      record = first || new(options)
      yield record if block_given?
      record.send(meth) if meth
    end
    return record
  end

  def create_or_update_and_do(meth, options)
    record = nil
    transaction do
      record = first || new
      record.attributes = options
      yield record if block_given?
      record.send(meth) if meth
    end
    return record
  end
end

ActiveRecord::Relation.send :include, FindOrCreateOnScopes