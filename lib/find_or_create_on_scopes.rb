# Adds `find_or_create`-type methods to named scopes.

module FindOrCreateOnScopes

  # Return this in a block from `find_or_create` or `create_or_update` to abort
  # the creation/updating of a record.
  ABORT_SAVE = Object.new

  # Locates a record according to the current scope. Returns the record if
  # found. If not found, creates a new record with the attributes of the current
  # scope and the provided attributes.
  #
  # @param [Array] args Arguments to pass to the `create` method.
  # @yield [record] Yields the record before it is saved.
  # @yieldparam [ActiveRecord::Base] record The found or created record before
  #   it is saved.
  # @yieldreturn [ABORT_SAVE, nil] If `ABORT_SAVE` the record is not saved.
  # @return [ActiveRecord::Base] The found or created record.

  def find_or_create(*args, &block)
    find_or_initialize_and_do :save, *args, &block
  end

  # Same as {#find_or_create} but calls `save!` instead of `save` on the record.
  #
  # @see #find_or_create

  def find_or_create!(*args, &block)
    find_or_initialize_and_do :save!, *args, &block
  end

  # Same as {#find_or_create} but does not save the record. Please note that
  # unless this method is called in a transaction, you might have a race
  # condition when trying to save the record.
  #
  # @see #find_or_create

  def find_or_initialize(*args, &block)
    find_or_initialize_and_do nil, *args, &block
  end

  # Locates a record according to the current scope. Updates the record with
  # the provided attributes if found. If not found, creates a new record with
  # the current scope's attributes and the provided attributes.
  #
  # @param [Array] args Arguments to pass to the `assign_attributes` method.
  # @yield [record] Yields the record before it is saved.
  # @yieldparam [ActiveRecord::Base] record The found or created record before
  #   it is saved.
  # @yieldreturn [ABORT_SAVE, nil] If `ABORT_SAVE` the record is not saved.
  # @return [ActiveRecord::Base] The found or created record.

  def create_or_update(*args, &block)
    create_or_update_and_do :save, *args, &block
  end

  # Same as {#create_or_update} but calls `save!` instead of `save` on the
  # record.
  #
  # @see #create_or_update

  def create_or_update!(*args, &block)
    create_or_update_and_do :save!, *args, &block
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

  def find_or_initialize_and_do(meth, *args)
    record = nil
    transaction do
      record = first || new(*args)
      if record.new_record?
        result = block_given? ? yield(record) : nil
        record.send(meth) if meth && result != ABORT_SAVE
      end
    end
    return record
  rescue StandardError => e
    if (defined?(Mysql2::Error) && e.kind_of?(Mysql2::Error)) ||
        (defined?(PG::Error) && e.kind_of?(PG::Error)) ||
        (defined?(ActiveRecord::JDBCError) && e.kind_of?(ActiveRecord::JDBCError)) ||
        e.kind_of?(ActiveRecord::ActiveRecordError)
      if e.to_s.include?('duplicate key value violates unique constraint') ||
          e.to_s.start_with?('Duplicate entry') ||
          e.kind_of?(ActiveRecord::RecordNotUnique)
        retry
      else
        raise
      end
    else
      raise
    end
  end

  def create_or_update_and_do(meth, *args)
    record = nil
    transaction do
      record = first || new
      record.assign_attributes(*args) unless args.empty?
      result = block_given? ? yield(record) : nil
      record.send(meth) if meth && result != ABORT_SAVE
    end
    return record
  rescue StandardError => e
    if (defined?(Mysql2::Error) && e.kind_of?(Mysql2::Error)) ||
        (defined?(PG::Error) && e.kind_of?(PG::Error)) ||
        (defined?(ActiveRecord::JDBCError) && e.kind_of?(ActiveRecord::JDBCError)) ||
        e.kind_of?(ActiveRecord::ActiveRecordError)
      if e.to_s.include?('duplicate key value violates unique constraint') ||
          e.to_s.start_with?('Duplicate entry') ||
          e.kind_of?(ActiveRecord::RecordNotUnique)

        # sadly there's no way to tell which keys are the duplicate ones from a
        # SQL error, so we just retry 3 times and then give up :/
        if @_focos_retries
          if @_focos_retries > 3
            raise
          else
            @_focos_retries += 1
            retry
          end
        else
          @_focos_retries = 1
          retry
        end
      else
        raise e
      end
    else
      raise e
    end
  end
end

ActiveRecord::Relation.include FindOrCreateOnScopes
