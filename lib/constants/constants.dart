const BASE_URL = '192.168.0.20:8080';

const filmsApi = '/api/v1/films';
const loginApi = '/api/v1/login';

const requestTimeOut = 90;

class GlobalPasser {
  static String _session;

  static set session(String session) => _session = session;

  static get sessionToken => _session;
}
