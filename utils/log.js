module.exports = {
  log(log) {
    /* eslint-disable-next-line no-console */
    console.log(`[${new Date()}] - ${JSON.stringify(log)}`);
  },
  error(err) {
    /* eslint-disable-next-line no-console */
    console.error(`[${new Date()}] - ${JSON.stringify(err)}`);
  },
};
