//when running, change to your ip
const String url = 'https://broncobondwebservice.onrender.com';
const String register = '$url/user/register';
const String login = '$url/user/login';
const String search = '$url/user/search';
const String logout = '$url/user/logout';
const String updateUser =
    '$url/user/updateUserInfo'; // replace :id with user's ID
const String updateInterests = '$url/user/updateUserInterests';
const String deleteUser = '$url/user';
const String getUserByID = '$url/user';
const String sendBondRequest = '$url/user/sendBondRequest';
const String revokeRequest = '$url/user/revokeBondRequest';
const String unbondUser = '$url/user/unbond';
const String acceptBondRequest = '$url/user/acceptBondRequest';
const String declineBondRequest = '$url/user/declineBondRequest';
