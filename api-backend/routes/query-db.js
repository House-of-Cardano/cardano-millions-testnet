const express = required('express');

const feedQuery = require('../controllers/query-db');

const router = express.Router();

router.get('/querydb', feedQuery.getQuery);

module.exports = router;