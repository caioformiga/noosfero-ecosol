# set the very basic fixtures for Noosfero
Fixtures.reset_cache
fixtures_folder = File.join(Rails.root, 'test', 'fixtures')
fixtures = ['environments', 'roles']
Fixtures.create_fixtures(fixtures_folder, fixtures)

