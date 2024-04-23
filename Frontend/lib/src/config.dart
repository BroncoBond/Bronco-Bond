const String url = 'http://ipconfig:8080';
//'https://broncobondwebservice.onrender.com';
const String register = '$url/api/user/register';
const String login = '$url/api/user/login';
const String search = '$url/api/user/search';
const String logout = '$url/api/user/logout';
const String updateUser =
    '$url/api/user/updateUserInfo'; // replace :id with user's ID
const String updateInterests = '$url/api/user/updateUserInterest';
const String deleteUser = '$url/api/user';
const String getUserByID = '$url/api/user';
const String sendBondRequest = '$url/api/user/sendBondRequest';
const String revokeRequest = '$url/api/user/revokeBondRequest';
const String unbondUser = '$url/api/user/unbond';
const String acceptBondRequest = '$url/api/user/acceptBondRequest';
const String declineBondRequest = '$url/api/user/declineBondRequest';
