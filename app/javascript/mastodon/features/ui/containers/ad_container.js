import { connect } from 'react-redux';

import { fetchSubscription } from 'mastodon/actions/payment';
import AdMonitor from 'mastodon/features/ad/components/ad_monitor';

const mapStateToProps = (state) => {
  const s = {
    enabled: state.getIn(['ad', 'enabled']),
  };
  return s;
};

const mapDispatchToProps = (dispatch) => ({
  fetchSubscription: () => dispatch(fetchSubscription()),
});

export default connect(mapStateToProps, mapDispatchToProps)(AdMonitor);
