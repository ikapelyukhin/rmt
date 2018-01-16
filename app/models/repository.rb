class Repository < ApplicationRecord

  has_many :repositories_services_associations
  has_many :services, through: :repositories_services_associations
  has_many :systems, through: :services
  has_many :products, -> { distinct }, through: :services

  scope :only_installer_updates, -> { unscope(where: :installer_updates).where(installer_updates: true) }
  scope :only_mirrored, -> { where(mirroring_enabled: true) }
  scope :only_custom, -> { where(scc_id: nil) }
  scope :only_scc, -> { where.not(scc_id: nil) }

  validates :name, presence: true
  validates :external_url, presence: true
  validates :local_path, presence: true

  class << self

    def remove_suse_repos_without_tokens!
      where(auth_token: nil).where('external_url LIKE ?', 'https://updates.suse.com%').delete_all
    end

    # Mangles remote repo URL to make a nicer local path, see specs for examples
    def make_local_path(url)
      uri = URI(url)
      path = uri.path.to_s
      path.gsub!(%r{^/repo}, '') if (uri.hostname == 'updates.suse.com')
      path
    end

    def by_id(repository_id, custom: false)
      return Repository.find_by(id: repository_id) if custom
      Repository.find_by(scc_id: repository_id)
    end

    def by_url(url)
      Repository.find_by(external_url: url)
    end


  end

  def refresh_timestamp!
    touch(:last_mirrored_at)
  end

  def change_mirroring!(mirroring_enabled)
    update_column(:mirroring_enabled, mirroring_enabled)
  end

  def custom?
    scc_id.nil?
  end

  def remove_if_custom
    destroy! if custom?
  end

end
