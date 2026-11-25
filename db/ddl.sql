CREATE TABLE Account(
  account_id INTEGER,
  username VARCHAR(25) NOT NULL,
  email VARCHAR(50) NOT NULL,
  password_hash CHAR(64) NOT NULL,
  region CHAR(2) NOT NULL,
  created_at DATE NOT NULL,
  PRIMARY KEY (account_id),
  UNIQUE (username),
  UNIQUE(email),
  CONSTRAINT Valid_Region CHECK (region IN ('NA', 'SA', 'EU', 'AF', 'OC', 'AS'))
);

CREATE TABLE Game(
  game_id INTEGER,
  title VARCHAR(100) NOT NULL,
  max_team_size INTEGER NOT NULL,
  PRIMARY KEY (game_id),
  CONSTRAINT Valid_Max_Team_Size CHECK (max_team_size >= 1)
);

CREATE TABLE Team(
  team_id INTEGER,
  captain_id INTEGER NOT NULL,
  name VARCHAR(50) NOT NULL,
  PRIMARY KEY (team_id),
  FOREIGN KEY (captain_id) REFERENCES Account(account_id)
);

CREATE TABLE Team_Invitation(
  invitation_id INTEGER,
  team_id INTEGER NOT NULL,
  sender_account_id INTEGER NOT NULL,
  recipient_account_id INTEGER NOT NULL,
  created_at DATE NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'pending',
  PRIMARY KEY (invitation_id),
  FOREIGN KEY (team_id) REFERENCES Team(team_id),
  FOREIGN KEY (sender_account_id) REFERENCES Account(account_id),
  FOREIGN KEY (recipient_account_id) REFERENCES Account(account_id),
  CONSTRAINT Valid_Status CHECK (status IN ('pending', 'accepted', 'rejected', 'canceled'))
);

CREATE TABLE Team_Member(
  team_id INTEGER,
  account_id INTEGER,
  PRIMARY KEY (team_id, account_id),
  FOREIGN KEY (team_id) REFERENCES Team(team_id),
  FOREIGN KEY (account_id) REFERENCES Account(account_ID)
);

CREATE TABLE Teammate_Post(
  post_id INTEGER,
  account_id INTEGER NOT NULL,
  game_id INTEGER NOT NULL,
  message VARCHAR(1000) NOT NULL,
  created_at DATE,
  status VARCHAR(30) NOT NULL DEFAULT 'pending',
  PRIMARY KEY (post_id),
  FOREIGN KEY (account_id) REFERENCES Account(account_id),
  FOREIGN KEY (game_id) REFERENCES Game(game_id),
  CONSTRAINT Valid_Status CHECK (status in ('pending', 'accepted', 'rejected', 'canceled'))
);

CREATE TABLE Tournament(
  tournament_id INTEGER,
  name VARCHAR(100) NOT NULL,
  max_entrants INTEGER NOT NULL,
  registration_deadline DATE,
  team_size INTEGER NOT NULL,
  organizer_id INTEGER NOT NULL,
  game_id INTEGER NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  bracket_format VARCHAR(25) NOT NULL,
  location VARCHAR(100) NOT NULL,
  status VARCHAR(25) NOT NULL DEFAULT 'open',
  prize_size DECIMAL(11,2) NOT NULL DEFAULT 0,
  prize_distribution_method VARCHAR(25),
  PRIMARY KEY (tournament_id),
  FOREIGN KEY (organizer_id) REFERENCES Account(account_id),
  FOREIGN KEY (game_id) REFERENCES Game(game_id),
  CONSTRAINT Valid_Max_Entrants CHECK (max_entrants >= 2 AND max_entrants <= 256),
  CONSTRAINT Valid_Team_Size CHECK (team_size >= 1 AND team_size <= 5),
  CONSTRAINT Valid_Bracket_Format CHECK (bracket_format IN ('single elimination',
    'double elimination')),
  CONSTRAINT Valid_Status CHECK (status IN ('open', 'closed', 'in progress', 'completed')),
  CONSTRAINT Valid_Prize_Size CHECK (prize_size >= 0),
  CONSTRAINT Valid_Prize_Distribution CHECK (prize_distribution_method in
    ('winner takes all'))
);

CREATE TABLE Entrant(
  entrant_id INTEGER,
  tournament_id INTEGER NOT NULL,
  account_id INTEGER,
  team_id INTEGER,
  seed INTEGER,
  final_placement INTEGER,
  PRIMARY KEY (entrant_id),
  FOREIGN KEY (tournament_id) REFERENCES Tournament(tournament_id),
  FOREIGN KEY (account_id) REFERENCES Account(account_id),
  FOREIGN KEY (team_id) REFERENCES Team(team_id),
  CONSTRAINT ValidEntrant CHECK ((account_id IS NOT NULL AND team_id IS NULL)
    OR (account_id IS NULL AND team_id IS NOT NULL))
);

CREATE TABLE Bracket_Set(
  set_id INTEGER,
  tournament_id INTEGER NOT NULL,
  round INTEGER NOT NULL,
  best_of INTEGER NOT NULL,
  entrant1_id INTEGER,
  entrant2_id INTEGER,
  winner_id INTEGER,
  winner_next_set_id INTEGER,
  loser_next_set_id INTEGER,
  bracket_side VARCHAR(25) NOT NULL DEFAULT 'winners',
  status VARCHAR(25) NOT NULL DEFAULT 'pending',
  PRIMARY KEY (set_id),
  FOREIGN KEY (tournament_id) REFERENCES Tournament(tournament_id),
  FOREIGN KEY (entrant1_id) REFERENCES Entrant(entrant_id),
  FOREIGN KEY (entrant2_id) REFERENCES Entrant(entrant_id),
  FOREIGN KEY (winner_id) REFERENCES Entrant(entrant_id),
  FOREIGN KEY (winner_next_set_id) REFERENCES Bracket_Set(set_id),
  FOREIGN KEY (loser_next_set_id) REFERENCES Bracket_Set(set_id),
  CONSTRAINT Valid_Status CHECK (status IN ('pending', 'in review', 'completed')),
  CONSTRAINT Valid_Bracket_Side CHECK (bracket_side IN ('winners', 'losers')),
  CONSTRAINT Valid_Best_Of CHECK (best_of IN (1, 3, 5, 7)),
  CONSTRAINT Valid_Round CHECK (round >= 1)
);

CREATE TABLE Set_Report(
  report_id INTEGER,
  set_id INTEGER NOT NULL,
  reporter_id INTEGER NOT NULL,
  reviewer_id INTEGER,
  status VARCHAR(25) NOT NULL DEFAULT 'pending',
  entrant1_score INTEGER NOT NULL,
  entrant2_score INTEGER NOT NULL,
  PRIMARY KEY (report_id),
  FOREIGN KEY (set_id) REFERENCES Bracket_Set(set_id),
  FOREIGN KEY (reporter_id) REFERENCES Account(account_id),
  FOREIGN KEY (reviewer_id) REFERENCES Account(account_id),
  CONSTRAINT Valid_Status CHECK (status IN ('pending', 'accepted', 'rejected'))
);

CREATE TABLE Game_Result(
  set_id INTEGER,
  game_number INTEGER,
  winner_id INTEGER,
  PRIMARY KEY (set_id, game_number),
  FOREIGN KEY (set_id) REFERENCES Bracket_Set(set_id),
  FOREIGN KEY (winner_id) REFERENCES Entrant(entrant_id)
);

CREATE TABLE Character(
  character_id INTEGER,
  game_id INTEGER NOT NULL,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY (character_id),
  FOREIGN KEY (game_id) REFERENCES Game(game_id)
);

CREATE TABLE Character_Pick(
  set_id INTEGER,
  game_number INTEGER,
  account_id INTEGER,
  character_id INTEGER NOT NULL,
  PRIMARY KEY (set_id, game_number, account_id),
  FOREIGN KEY (account_id) REFERENCES Account(account_id),
  FOREIGN KEY (character_id) REFERENCES Character(character_id),
  FOREIGN KEY (set_id, game_number) REFERENCES Game_Result(set_id, game_number)
);