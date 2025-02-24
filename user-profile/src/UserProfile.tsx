import Payments from "payments/Payments";
import * as R from 'ramda';

const UserProfile = () => {
  const name = R.head(["User Profile", "Other"]);
  return (
    <div>
      <h1>{name}</h1>
      <p>Start building amazing things with Rsbuild.</p>
      <Payments />
    </div>
  );
};

export default UserProfile;
