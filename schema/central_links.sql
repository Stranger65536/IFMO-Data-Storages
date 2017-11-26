CREATE DATABASE LINK BRANCH_1 CONNECT TO ${BRANCH_1_USER} IDENTIFIED BY ${BRANCH_1_PASSWORD} USING
  '(DESCRIPTION=
    (ADDRESS=
     (PROTOCOL=TCP)
     (HOST=${BRANCH_1_HOST})
     (PORT=${BRANCH_1_PORT}))
    (CONNECT_DATA=
     (SERVICE_NAME=${BRANCH_1_PDB})))';

CREATE DATABASE LINK BRANCH_2 CONNECT TO ${BRANCH_2_USER} IDENTIFIED BY ${BRANCH_2_PASSWORD} USING
  '(DESCRIPTION=
    (ADDRESS=
     (PROTOCOL=TCP)
     (HOST=${BRANCH_2_HOST})
     (PORT=${BRANCH_2_PORT}))
    (CONNECT_DATA=
     (SERVICE_NAME=${BRANCH_2_PDB})))';