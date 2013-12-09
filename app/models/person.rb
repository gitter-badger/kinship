class Person < ActiveRecord::Base
	before_validation :default_values
	before_create :build_default_birth, :build_default_death

	# Photo stuff
	has_attached_file :photo, 
    :styles => { :medium => "256x256>", :small => "64x64>", :tiny => "24x24>" },
		:default_url => :set_default_avatar,
		:url  => "/assets/photos/:id/:style/:basename.:extension",
		:path => ":rails_root/public/assets/photos/:id/:style/:basename.:extension"
	validates_attachment_size :photo, :less_than => 5.megabytes
	validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png']

	# Birth
	has_one :birth, :foreign_key => "child_id"
	accepts_nested_attributes_for :birth
	validates_associated :birth

	# Death
	has_one :death
	accepts_nested_attributes_for :death
	validates_associated :death

	# User
	has_one :user

	# Spouse

	# Other Validations
	# Allow blank values; see private method default_values for details
	validates :first_name, :presence => true, :allow_blank => true
	validates :last_name, :presence => true, :allow_blank => true
	validates :spouse_id, :presence => true, :allow_blank => true

	VALID_GENDERS = ['M', 'F']
	validates :gender, :presence => true, inclusion: {in: VALID_GENDERS},:allow_blank => true

	def father
		birth.father
	end

	def mother
		birth.mother
	end

	def full_name
		first_name + ' ' + last_name
	end

	def full_name_and_id
		first_name + ' ' + last_name + " \(#{id}\)"
	end

	def alive?
		return !death.dead
	end

	def children
		# TODO: Might be able to minimize the search here by basing it on gender
		children_ids = Birth.find_all_by_father_id(id).map {|elt| elt.child_id}
		children_ids += Birth.find_all_by_mother_id(id).map {|elt| elt.child_id}
		return Person.find_all_by_id(children_ids)
	end

	def age(date=Date.today)
		return nil if birth.date.nil?

		if (date === 'death_date')
			return nil if death.date.nil?
			date = death.date
		end

		diff = date - birth.date
		age = (diff / 365.25).floor
		age
	end

	def events
	    e = []

	    if !birth.nil?
		e.push(birth)
	    end
	    if death.dead
		e.push(death)
	    end

	    return e
	end

	def self.all_genders
		VALID_GENDERS
	end

	private
		def default_values
			# These values might not be known when we build the user, but we
			# still want them to have a value, so we'll set them to blank

			# Some examples where we might not know this information:
			#  We want to add a father, because we know where he was born, but
			#  we don't know his name.
			#  We know someone has a sibling, but we don't know their gender
			self.first_name ||= ''
			self.last_name ||= ''
			self.gender ||= ''
		end
		def build_default_birth
			build_birth if birth.nil? 
		end
		def build_default_death
			build_death if death.nil? 
		end
    def set_default_avatar
      if gender == "F"
        default_avatar = "/assets/default_:style_female_avatar.png"
      else
        default_avatar = "/assets/default_:style_male_avatar.png"
      end
    end
end
