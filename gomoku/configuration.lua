local configuration = {
  GAME = "gomoku",

  SIZE=15,
  INITIAL={ 0,0,0,0,0,0,0,0,0 },
  -- FINAL={1, 2, 3, 4, 5, 6, 7, 8, 9 },

}

package.path=package.path..';./common/?.lua'..';./gomoku/?.lua'
return configuration